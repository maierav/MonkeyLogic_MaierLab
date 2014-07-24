################################################################################
#  flashattend.tcl                                                             #
#                                                                              #
#  AVM 2005                                                                    #
#  GKA 2008                                                                    #
################################################################################

set home "C:/Program Files/Stim/stim"
#add vergence cues
source $home/utils/experutils.tcl
source C:/screen.tcl
#source $home/utils/gkautils.tcl
source gkautils.tcl
# Import all gkautils functions (if ever not all are wanted, just provide a list
# of which ones to import):
namespace import -force gkautils::*
load rivsines
load rivbkg
load polygon
load disk

set ::GOBJ_TYPE_ID(rivgrat)    [gobjType [rivgrat]]
set ::GOBJ_TYPE_ID(background) [gobjType [background]]
set ::GOBJ_TYPE_ID(polygon)    [gobjType [polygon]]
set ::GOBJ_TYPE_ID(disk)       [gobjType [disk]]

resetObjList
set StereoMode 1
redraw

### EXPERIMENTAL PARAMETERS:
set ::WARMUP     0 ;# Contrast change is always large
set ::CUEPERSIST 1 ;# Cue persists after appearing; otherwise quickly disappears
set ::USEPROBES  0 ;# 1=Stimuli appear as probes instead of full target size
                    # (not yet implemented)
set ::USEPHOTOSIGNAL 0;# Show the photodiode probe (t/f)?


set ::ANIMATION_WORKS 0 ;# Set to 1 if STIM seems to process animation correctly
set ::REDGREEN 1 ;# Set to 1 for red/green stimuli instead of blue/yellow

### MAJOR PARAMETERS:
set ::NUM_TARGETS 4
set ::TARGET_CONFIG RING
# Random parameter occurance ratios:
set ::ADAPT_EYE_RATIO {1 1}   ;# Left eye : Right eye
set ::ADAPT_COLOR_RATIO {1 1} ;# Yellow : Blue (or Green : Red)
#set ::ADAPT_ORI_RATIO {1 1}   ;# Vertical : Horizontal - now locked to color
set ::STIM_ADAPT_RATIO {1 1}  ;# Stimulus in suppressors : adaptors
#er###set ::CONTRAST_CHANGE_RATIO {0 1 1 1 2} ;# Largest contrast occurs more often and n/c not at all

#set ::CONTRAST_CHANGE_RATIO {1 1 1 1 1}; NOT IN USE!

#er###set ::CONTRAST_CHANGE_RATIO {1 0 0 4 0}
#er###set ::CONTRAST_CHANGE_RATIO {2 1 1 1 1} ; # 33% catch trials  
#set ::CONTRAST_CHANGE_RATIO {1 0 0 0 0} ;# Never stimulate

#set ::CONTRAST_CHANGE_VALUE {0 0.2 0.3 0.4 0.8} ;# NOT IN USE!


#er##set ::CONTRAST_CHANGE_VALUE {0 0.05 0.1 0.2 0.3} 
#set ::CUE_SHOW_RATIO {0 1} ;# Always show
#set ::CUE_SHOW_RATIO {1 4} ;# Show 80% of the time
set ::CUE_SHOW_RATIO {0 1} ;# 1 0 Never show / 0 1 Always show
# Number of mismatches : number of matches:
#set ::CUE_MATCH_RATIO {0 1} ;# Always matches
set ::CUE_MATCH_RATIO {1 9} ;# Mismatches 10% of the time
#set ::CUE_MATCH_RATIO {1 4} ;# Mismatches 20% of the time
set ::STIM_INDEX_RATIO [listInit $NUM_TARGETS 1] ;# Frequency of stimulus
                                                  # appearing at each pos
set ::CUE_INDEX_RATIO [listInit [expr $NUM_TARGETS-1] 1] ;# Frequency of cue
                                                   # appearing at each pos (only
                                                   # if not cueStimMatch)
#set ::BRFS_RATIO {0 4}

set ::BRFS_RATIO {1 4}


#er##set ::BRFS_RATIO {1 0}

### HANDLE EXPERIMENTAL PARAMETERS:
if {$::WARMUP} {
   set ::CONTRAST_CHANGE_RATIO {0 0 0 0 1} ;# Contrast change is always large

###    set ::CONTRAST_CHANGE_RATIO {1 0 0 0 1} ;# Contrast change is always large, and half of trials are catch trials
}


### CONSTANTS AND SHORTHANDS:
set ::PI [expr {acos(-1)}] ;# Approximate pi
set ::EYE_NONE  {0 0}
set ::EYE_LEFT  {0 1}
set ::EYE_RIGHT {1 0}
set ::EYE_BOTH  {1 1}
set ::PHOTOSIGNAL_POSITION {21.5 -12} ;# Location for photodiode probe
set ::PHOTOSIGNAL_SIZE .2 ;# Size of photodiode probe
set ::PHOTOSIGNAL_EYE  $::EYE_RIGHT

namespace eval ::flashattend {
    # A list of all the ESS states that can be invoked:
    set allStates [list start startobs fixate targets_on cue_on cue_off \
                        targets_flash change_on change_off post_change \
                        post_resp abort success endobs interobs finale]
    # A list of all the ESS states relevant to changing the STIM graphics:
    set graphStates [list startobs fixate targets_on cue_on cue_off \
                          targets_flash change_on change_off post_change \
                          post_resp abort success]
    # Graphics states:
    # startobs:      From the beginning of the observation to the appearance of
    #                a fixation spot
    # fixate:        From the appearance of the fixation spot to the appearance
    #                of the targets
    # targets_on:    From the appearance of the targets to the appearance of the
    #                cue
    # cue_on:        From the appearance of the cue to the disappearance of the
    #                cue
    # cue_off:       From the disappearance of the cue to the flash
    # targets_flash: From the flash to the stimulus change
    # change_on:     From the onset of the stimulus change to the restoration of
    #                the stimulus
    # change_off:    From the restoration of the stimulus to...?
    # post_change:   From ...? to the monkey's response
    # post_resp:     From the monkey's response to the end of the trial
    # abort:         From a failure to the next trial
    # success:       From the end of the trial to the next trial
    
    # Array holding all graphics object handles:
    array set graphObjs {
        bkgd        {}
        fix         {}
        cue         {}
        adaptors    {}
        suppressors {}
        stim_adapts {}
        stim_supps  {}
        err         {}
		photosignal {}
    }
    # Graphics objects:
    # bkgd:        Stimulus background (vergence cues)
    # fix:         Fixation spot
    # cue:         Attention cue (endogeneous or exogeneous)
    # adaptors:    Adaptor targets
    # suppressors: Suppressor targets
    # stim_adapts: Decremented contrast targets for adaptors
    # stim_supps:  Decremented contrast targets for suppressors
    # err:         Yellow screen flash to indicate an error
    # photosignal: Probe stimulus for the photodiode
    
    # Array holding the glist groups for each graphics object:
    array set graphObjStates {\
        bkgd        {fixate targets_on cue_on cue_off targets_flash change_on \
                     change_off post_change post_resp}
        fix         {fixate targets_on cue_on cue_off targets_flash change_on \
                     change_off post_change post_resp}
        cue         {cue_on cue_off targets_flash change_on change_off \
                     post_change}
        adaptors    {targets_on cue_on cue_off targets_flash change_on\
                     change_off post_change}
        PAadaptors  {targets_on cue_on cue_off}
        suppressors {targets_flash change_on change_off post_change}
        stim        {change_on}
        err         {abort}
		photosignal {fixate cue_on targets_flash change_off}
    }
    # The following line is for testing the quality of flash suppression.
    # Comment it out when doing the flashattend task.
    #set graphObjStates(adaptors) {cue_on cue_off targets_flash change_on \
    #    change_off post_change}
    if {!$::CUEPERSIST} { set graphObjStates(cue) {cue_on} }
    if {!$::USEPHOTOSIGNAL} { set graphObjStates(photosignal) {} }
}
 namespace eval ::graphPars {
    #set bkgdCol {75 75 75}     ;# Background color (dark gray)
    set bkgdCol {127 127 127}  ;# Background color (light gray)
    eval setBackground $bkgdCol
    set fixColor {0 0 0}       ;# Fixation spot color (black)
    #ER# set fixSpotSize 0.05       ;# Fixation spot size, in visual degrees
    set fixSpotSize 0.2
    set fixCrossSize 0.25      ;# Fixation cross size
    set cueColor {255 255 255} ;# White
    #er##set cueSize  0.5
    #er##set cueSize 2.5
     set cueSize 0.8
    #er## set cueSize .7
     set errColor {255 255 0} ;# Yellow
    set errFlashTime 100 ;# Duration of the yellow screen flash in ms
    
    # Display parameters for blue targets:
    array set targetBlue {
        color   {0 0 250}
        weight  1
        baseCon 1
    }
    # Display parameters for yellow targets:
    array set targetYellow {
        color   {120 120 0}
        weight  1
        baseCon 1
    }
    # Display parameters for red targets: ##ER##changed from 0.5 baseCon
    array set targetRed {
        color   {255 0 0}
        weight  1
	baseCon 1
    }
    # Display parameters for green targets:
    array set targetGreen {
        color   {0 255 0}
        weight  1
        baseCon 1
    }
    if {$::REDGREEN} {
        set targetColors {::graphPars::targetGreen ::graphPars::targetRed}
    } else {
        set targetColors {::graphPars::targetYellow ::graphPars::targetBlue}
    }
    set targetSpatialFreq 1.3; # Spatial frequency of target grating
    set targetDiameter 2.2    ;# Size of targets

   ############## {red, green}
   set targetOris {45 135}  ;# Target orientations; horizontal or vertical
    #set targetOris {135 45}
   # set targetOris {0 90} ; # 0= vertical 
    #set targetOris {90 0}

    
    set targetConfig $::TARGET_CONFIG ;# Target placement configuration
    set probeScale 0.1 ;# Size of probe relative to target, must be <sqrt(0.5)
}
namespace eval ::trialPars {
    # Parameters that may vary from trial to trial.
    set numTargets {} ;# Number of targets to display
    set targetEcc  {} ;# Target eccentricity
    set targetAz   {} ;# Azimuthal offset of first target
    set targetLocs {} ;# Positions of targets
    set adaptColor {} ;# Color for adaptors
    set adaptOri   {} ;# Orientation for adaptors
    set adaptEye   {} ;# Eye to display adaptors to
    set supprColor {} ;# Color for suppressors
    set supprOri   {} ;# Orientation for suppressors
    set supprEye   {} ;# Eye to display suppressors to
    set stimIndex  {} ;# At which location will the stimulus appear?
    set stimPos    {} ;# Coordinates of stimulus in {ecc az} polar
    set stimAdapt  {} ;# Is the stimulus in the adaptors (1) or suppressors (0)?
    set stimChange {} ;# Stimulus contrast change magnitude
    set cueShow    {} ;# Show the cue or not?
    set cueIndex   {} ;# Which location will we cue?
    set cuePos     {} ;# Coordinates of cued target in {ecc az} polar
    set cueType    {} ;# ENDO or EXO
    set brfs       {}
}
proc loadVariablePars {} {
    set ::gStimPars StimPars
    if [dg_exists $::gStimPars] {
        dg_delete $::gStimPars
    }
    set dg [dg_create $::gStimPars]
    # Adaptors appear in the right eye (t/f):
    newStmParam adaptEyeRight     [countOutValues $::ADAPT_EYE_RATIO]
    # Adaptors are blue (t/f):
    newStmParam adaptColorBlue    [countOutValues $::ADAPT_COLOR_RATIO]
    # Adaptors are horizontal (t/f):
    #newStmParam adaptOriHoriz     [countOutValues $::ADAPT_ORI_RATIO]
    # Stimulus is in the adaptors (t/f):
    newStmParam stimAdapt         [countOutValues $::STIM_ADAPT_RATIO]
    # Index to ::graphPars::targetContrastChanges:
    newStmParam contrastChange "0 0.2 0.3 0.4 0.8";

    #newStmParam contrastChange "0 0.3 0.6 0.8";

    # BUG FIX (countOutValues can't do floats)
    #[countOutValues $::CONTRAST_CHANGE_RATIO $::CONTRAST_CHANGE_VALUE]

    # Show the cue (t/f):
    newStmParam showCue           [countOutValues $::CUE_SHOW_RATIO]
    # Cue matches the stimulus (t/f):
    newStmParam cueStimMatch      [countOutValues $::CUE_MATCH_RATIO]
    # Stimulus position index:
    newStmParam stimIndex         [countOutValues $::STIM_INDEX_RATIO]
    # Cue position index (if not cueStimMatch):
    newStmParam cueIndex          [countOutValues $::CUE_INDEX_RATIO]
    # Binocular Rivalry / Flash Suppression Experiment:
    newStmParam brfs              [countOutValues $::BRFS_RATIO] ;#0

    
    R_getBlock 0;
}
loadVariablePars


################################################################################
# ESS State Procedures
proc RS_start {} {
    # Code to execute at the beginning of a series of observations
	puts {Start experiment}
}
proc RS_startobs {centerX centerY targEcc targAz endoCue} {
    # Code to execute at the beginning of each observation
    setTrialPars $targEcc $targAz $endoCue ;# Generate random, observation-wise
                                            # parameters
    setupGraphics ;# Create all graphics objects and initialize the glist
    setTranslate $centerX $centerY
    
    glistSetCurGroupByLabel startobs
    redraw
}
proc RS_fixate {} {        # Display the fixation spot
    glistSetCurGroupByLabel fixate
    redraw
}
proc RS_targets_on {} {    # Display targets
    glistSetCurGroupByLabel targets_on
    redraw
}

proc RS_targets_off {} {   #ER## Hide targets
    glistSetCurGroupByLabel startobs
    redraw
}

proc RS_cue_on {} {        # Display cue
    glistSetCurGroupByLabel cue_on
    redraw
}
proc RS_cue_off {} {       # Hide cue
    glistSetCurGroupByLabel cue_off
    redraw
}
proc RS_targets_flash {} { # Flash suppression
    glistSetCurGroupByLabel targets_flash
    redraw
}
proc RS_change_on {} {     # Stimulus change
    glistSetCurGroupByLabel change_on
    redraw
}
proc RS_change_off {} {    # Remove stimulus change
    #glistSetCurGroupByLabel change_off
    #redraw
}
proc RS_post_change {} {   # Fixation after stimulus change
    glistSetCurGroupByLabel post_change
    redraw
}
proc RS_postresp {} {      # Fixation after response
    glistSetCurGroupByLabel post_resp
    redraw
}
proc RS_abort {reason} {         # Abort trial
    glistSetCurGroupByLabel abort
    redraw
    if {!$::ANIMATION_WORKS} {
        # If STIM doesn't process the event loop properly, animation doesn't
        # work automatically. This means that in order to animate the error
        # stimulus, RS_abort can't return immediately but must wait to update
        # the stimulus. These commands do the manual animation.
        after $::graphPars::errFlashTime
        glistNextFrame
        redraw
    }
}
proc RS_success {reason} {       # Successful trial
    glistSetCurGroupByLabel success
    redraw
}
proc RS_endobs {} {        # End of observation; clean up
    resetObjList
}
proc RS_interobs {} {
    # Between observations; pretty much no responsibilities on this side
}
proc RS_pause {} {
    resetObjList
    glistInit 1
    set obj [polygon]
    polycolor $obj .5 0 0
    polyverts $obj {-2. -1. 1. 2. 2. 1. -1. -2.} {1. 2. 2. 1. -1. -2. -2. -1.}
    glistAddObject $obj 0
    glistSetVisible 1
    redraw
}
proc RS_finale {} {
    # End of all observations; pretty much no responsibilities on this side
}

################################################################################
# ESS Callback Procedures
proc RC_start {} { # Operator pressed START button in ESS
}
proc RC_reset {} { # Operator pressed RESET button in ESS
}
proc RC_quit {} { # Operator pressed QUIT button in ESS
	resetObjList
	redraw
}

################################################################################
# Other ESS Remote Procedures
proc R_getAllPars {} {
    set pars {}
    
    set adaptEye [eyeListToNum $::trialPars::adaptEye]
    set supprEye [eyeListToNum $::trialPars::supprEye]
    set adaptColorBlue [expr int([R_getStmParamByName adaptColorBlue])]
    set supprColorBlue [expr 1-$adaptColorBlue]
    
    lappend pars $adaptEye                ;# 1 Adaptor eye
    lappend pars $::trialPars::adaptOri   ;# 2 Adaptor orientation
    lappend pars $adaptColorBlue          ;# 3 Are adaptors blue?
    lappend pars $supprEye                ;# 4 Suppressor eye
    lappend pars $::trialPars::supprOri   ;# 5 Suppressor orientation
    lappend pars $supprColorBlue          ;# 6 Are suppressors blue?
    lappend pars $::trialPars::stimAdapt  ;# 7 Is stimulus in adaptors?
    lappend pars $::trialPars::stimChange ;# 8 Contrast change magnitude
    lappend pars $::trialPars::stimIndex  ;# 9 Index of stimulus
    lappend pars $::trialPars::showCue    ;#10 Cue is shown or not?
    lappend pars $::trialPars::cueIndex   ;#11 Index of cue
    lappend pars $::NUM_TARGETS           ;#12 How many targets are used?
    lappend pars $::WARMUP                ;#13 Is this a warmup?
    lappend pars $::trialPars::brfs       ;#14 Is this binocular rivalry?
    lappend pars $::CUEPERSIST            ;#15 Is cue set to persist?
    lappend pars $::USEPROBES             ;#16 Are probes being used?
    lappend pars $::REDGREEN              ;#17 Are targets red/green?
    
    return $pars
}
proc R_getVal {valName} {
    switch $valName {
        stimIndex      {return $::trialPars::stimIndex}
        cueIndex       {return $::trialPars::cueIndex}
        contrastChange {return $::trialPars::stimChange}
        cuePersist     {return $::CUEPERSIST}
    }
}

################################################################################
# Internal Procedures
proc eyeListToNum {eye} {
    set left [lindex $eye 1]
    set right [lindex $eye 0]
    if {$left && $right} {
        return 3
    } elseif {$right} {
        return 2
    } elseif {$left} {
        return 1
    } else {
        return 0
    }
}
proc getStateIndex {state} {
    set ind [lsearch -exact $::ESS_StateList $state]
    if {$ind==-1} {
        return 0
    } else {
        return $ind
    }
}
proc setTrialPars {targEcc targAz endoCue} {
    set ::trialPars::targetEcc $targEcc
    set ::trialPars::targetAz $targAz
    set ::trialPars::targetLocs [getTargetLocs $::NUM_TARGETS  \
        $targEcc $targAz $::graphPars::targetConfig]
    if {$endoCue} {
        set ::trialPars::cueType ENDO
    } else {
        set ::trialPars::cueType EXO
    }
    if {[R_nextTrial]==-1} {
        R_getBlock 0
        R_nextTrial
    }
    set adaptEyeRight   [expr int([R_getStmParamByName adaptEyeRight])]
    set adaptColorBlue  [expr int([R_getStmParamByName adaptColorBlue])]
    #set adaptOriHoriz   [expr int([R_getStmParamByName adaptOriHoriz])]
    set adaptOriHoriz [expr !$adaptColorBlue]
    set brfs            [expr int([R_getStmParamByName brfs])]
    if {$brfs} {
        set stimAdapt   [expr int([R_getStmParamByName stimAdapt])]
    } else { # If this is phys. alt., stim can't be in adaptors:
        set stimAdapt   0
    }
    set contrastChange  [R_getStmParamByName contrastChange]
    set showCue         [expr int([R_getStmParamByName showCue])]
    if {$showCue} {
        set cueStimMatch [expr int([R_getStmParamByName cueStimMatch])]
    } else { ;# If the cue isn't shown, there can be no mismatch:
        set cueStimMatch 1
    }
    set stimIndex       [expr int([R_getStmParamByName stimIndex])]
    if {$cueStimMatch} {
        set cueIndex $stimIndex
    } else {
        set cueIndex    [expr int([R_getStmParamByName cueIndex])]
        if {$cueIndex >= $stimIndex} {
            incr cueIndex
        }
    }
    set supprColorBlue [expr !$adaptColorBlue]
    set supprOriHoriz  [expr !$adaptOriHoriz]
    set ::trialPars::adaptColor \
        [lindex $::graphPars::targetColors $adaptColorBlue]
    set ::trialPars::adaptOri \
        [lindex $::graphPars::targetOris $adaptOriHoriz]
    if {$adaptEyeRight} {
        set ::trialPars::adaptEye $::EYE_RIGHT
        set ::trialPars::supprEye $::EYE_LEFT
    } else {
        set ::trialPars::adaptEye $::EYE_LEFT
        set ::trialPars::supprEye $::EYE_RIGHT
    }
    set ::trialPars::supprColor \
        [lindex $::graphPars::targetColors $supprColorBlue]
    set ::trialPars::supprOri \
        [lindex $::graphPars::targetOris $supprOriHoriz]
    set ::trialPars::stimIndex $stimIndex
    set ::trialPars::stimPos [lindex $::trialPars::targetLocs $stimIndex]
    set ::trialPars::stimAdapt $stimAdapt
    set ::trialPars::stimChange $contrastChange
    set ::trialPars::showCue $showCue
    set ::trialPars::cueIndex $cueIndex
    set ::trialPars::cuePos [lindex $::trialPars::targetLocs $cueIndex]
    set ::trialPars::brfs $brfs
}
proc makeBackground {} {
    #set bkgd [background]
    #background_type $bkgd dots;
    #background_elementcolori $bkgd 1 1 1
    #background_stmmask $bkgd ellipse
    #background_stmsize $bkgd 10.0 10.0
    #background_density $bkgd 5.0
    #background_elementsize $bkgd 5
    #background_visible $bkgd 1
    #scaleObj $bkgd 2.5 2.5
    set bkgd [disk]
    diskcolor $bkgd 0 0 0
    diskradii $bkgd 15 90
    diskparams $bkgd 20 100
    eval setEye $bkgd $::EYE_BOTH
    return $bkgd
}
proc makeFixation {type {eye {1 1}}} {
    set type [string toupper $type]
    if [string equal $type SPOT] {
        set fix [disk]
        diskradii $fix 0 1
        eval diskcolor $fix [icolor_to_fcolor $::graphPars::fixColor]
        scaleObj $fix $::graphPars::fixSpotSize $::graphPars::fixSpotSize
        eval setEye $fix $eye
    } elseif [string equal $type CROSS] {
        set fix [cross 0.1]
        eval polycolor $fix [icolor_to_fcolor $::graphPars::fixColor]
        scaleObj $fix $::graphPars::fixCrossSize $::graphPars::fixCrossSize
        eval setEye $fix $eye
    }
    return $fix
}
proc cross {thickness} {
    # There appears to be a bug in polygon that prevents this from working
    # correctly.
    set r 0.5;   # Cross radius
    set w [expr $thickness / 2.0]; # semi-width of cross
    set xs "-$r -$w -$w $w $w $r $r $w $w -$w -$w -$r"
    set ys "$w $w $r $r $w $w -$w -$w -$r -$r -$w -$w"
    set cross [polygon]
    polyverts $cross $xs $ys
    return $cross
}
proc setupGraphics {} {
    # Create a graphics slot for every graphics state:
    resetObjList
    glistInitLabels $::flashattend::graphStates
    eval setBackground $::graphPars::bkgdCol
    
    glistSetVisible 1
    createAllObjects
    addBkgdToGlist
    addFixToGlist
    addCueToGlist
    addAdaptorsToGlist
    addSuppressorsToGlist
    addStimToGlist
    addErrToGlist
    addPhotosignalToGlist
}
proc makeGrating {color intensity weight orient spatfreq size} {
    # Create a grating target by parameters
    # color: Grating color as a 3-element integer 0-255 list
    # intensity: Grating intensity, 0-1 (roughly contrast; see gratingColorList)
    # weight: Grating dark bar weight, 0-1 (see gratingColorList)
    # orient: Grating orientation (angular degrees)
    # spatfreq: Spatial frequency of grating
    # size: Diameter of grating in degrees
    #
    # Returns: a two-element list of the grating and a mask to make the grating
    #     circular. These two objects can be manipulated together using the 
    #     "multiCmd" command from gkautils.tcl.
    
    # Compute the grating colors from color parameters:
    set colorList \
        [gratingColorList $color $intensity $weight $::graphPars::bkgdCol]
    # Create the grating:
    set grat [rivgrat] ;# Create square patch of sinewave grating
    #rivgrat_speed $grat $speed
    set cycles_per_img [expr $spatfreq*$size]
    rivgrat_ncycles $grat $cycles_per_img ;# Set number of cycles in grating
    rivgrat_ori $grat $orient ;# Set grating orientation, in angular degrees
    rivgrat_type $grat SINE ;# Set grating to sine rather than square wave
    rivgrat_color $grat $colorList ;# Set grating colors
    rivgrat_gabor $grat 0 ;# No gabor envelope (1=gabor, 2=pixelated circle)
    scaleObj $grat $size $size
    
    # Create a mask for the grating:
    set mask [disk] ;# Create masking disk to match the background
    eval diskcolor $mask [icolor_to_fcolor $::graphPars::bkgdCol]
    diskparams $mask 20 100 ;# Defines number of vertices, etc.
    diskradii $mask 0.5 0.8 ;# Size to mask everything but a circle
    scaleObj $mask $size $size
    
    return "$grat $mask"
}
proc gratingColorList {color intensity weight bgcolor} {
    # Return a color list suitable for being passed to rivgrat_color that will
    # produce a sine grating characterized by the color $color.
    # color:     The characteristic color of the grating; should be a three-
    #            element list of 0-255 RGB values.
    # intensity: A value between 0 and 1 representing the intensity of the
    #            grating; as the value approaches 0, the grating fades to the
    #            background color. If $weight is set to make the grating roughly
    #            isoluminant with the background, this number should roughly
    #            represent contrast.
    # weight:    A value between 0 and 1 representing the weight of the dark
    #            bars in the grating; at 1, the bars are fully black, and as
    #            the value approaches zero, the grating approaches a uniformly
    #            colored patch. This value can be adjusted to try to make the
    #            grating isoluminant with the background.
    # bgcolor:   The color of the background; an RGB list as with $color
    set mod {}
    set mean {}
    foreach ind $color bgind $bgcolor {
        lappend mod  [expr int($intensity*$ind*$weight/2.0)]
        lappend mean \
            [expr int($intensity*$ind*(1-$weight/2.0)+(1-$intensity)*$bgind)]
    }
    return [concat $mod $mean]
}
proc getTargetLocs {num ecc azoff config {span 90}} {
    # Get a list of target positions in polar coordinates
    # num: The number of targets
    # ecc: The eccentricity of the targets, in visual degrees
    # azoff: The azimuthal offset of the targets from the positive polar axis
    # config: The target configuration; see below
    # span: An option for ARC configuration; see below
    # Valid config options:
    #    RING:  Full ring around the fixation
    #    HEMI:  Half a ring around the fixation, in the upper visual field
    #    ARC:   An arc around the fixation; supply the span argument to specify
    #           the span, in angular degrees, of the arc.
    set config [string toupper $config]
    set locs {}
    if {[string equal $config RING]} {
        for {set k 0} {$k < $num} {incr k} {
            lappend locs "$ecc [expr $k*360/$num+$azoff]"
        }
    } elseif {[string equal $config HEMI]} {
        for {set k 0} {$k < $num} {incr k} {
            lappend locs "$ecc [expr $k*180/($num-1)+$azoff]"
        }
    } elseif {[string equal $config ARC]} {
        for {set k 0} {$k < $num} {incr k} {
            lappend locs "$ecc [expr $k*$span/($num-1)+$azoff]"
        }
    }
    return $locs
}
proc makeCue {cuePos cueSize type {eye {1 1}}} {
    # Create endogeneous or exogeneous attention cue.
    # cuePos:  Two-element list of {eccentricity azimuth} polar coordinates of
    #          cued stimulus.
    # cueSize: For endo cue, the length of the cue; for exo cue, the diameter of
    #          the ring.
    # type:    Either ENDO or EXO.
    # eye:     (optional) Which eye, defaults to both eyes.
    set type [string toupper $type]
    set cueEcc [lindex $cuePos 0]
    set cueAz  [lindex $cuePos 1]
    if {[string equal $type ENDO]} {
        set cue [polygon]
        polyverts $cue {0. 0. 1. 1.} {-0.5 0.5 0.5 -0.5}
        eval polycolor $cue [icolor_to_fcolor $::graphPars::cueColor]
        scaleObj $cue $cueSize 0.1
        rotateObj $cue $cueAz 0 0 1
    } elseif {[string equal $type EXO]} {
        set cue [disk]
        diskparams $cue 20 500
        diskradii $cue 1 1.1
        eval diskcolor $cue [icolor_to_fcolor $::graphPars::cueColor]
        scaleObj $cue $cueSize $cueSize
        translatePolar $cue $cueEcc $cueAz
    }
    eval setEye $cue $eye
    return $cue
}
proc makeErrStim {color} {
    set err [polygon]
    polyverts $err {-45. 45. 45. -45.} {45. 45. -45. -45.}
    eval polycolor $err [icolor_to_fcolor $color]
    eval setEye $err $::EYE_BOTH
    return $err
}
proc makeTargets {colorSpec ori eye} {
    set color   [set [set colorSpec](color)]
    set weight  [set [set colorSpec](weight)]
    set baseCon [set [set colorSpec](baseCon)]
    set targets {}
    foreach loc $::trialPars::targetLocs {
        set targ [makeGrating $color $baseCon $weight $ori \
            $::graphPars::targetSpatialFreq $::graphPars::targetDiameter]
        eval multiCmdExp translatePolar [list $targ] $loc
        eval multiCmdExp setEye [list $targ] $eye
        lappend targets $targ
    }
    return $targets
}
proc changeTarget {target colorSpec ori contrastChange} {
    set color     [set [set colorSpec](color)]
    set weight    [set [set colorSpec](weight)]
    set baseCon   [set [set colorSpec](baseCon)]
    set intensity [expr $baseCon*(1-$contrastChange)]
    set grats     [selectObjsByType $target $::GOBJ_TYPE_ID(rivgrat)]
    set colorList \
        [gratingColorList $color $intensity $weight $::graphPars::bkgdCol]
    multiCmd rivgrat_color $grats $colorList
    multiCmd rivgrat_ori   $grats $ori
}
proc makePhotosignal {} {
    set photosignal [disk]
    diskcolor $photosignal 1 1 1
    diskradii $photosignal 0 1
    scaleObj  $photosignal $::PHOTOSIGNAL_SIZE
    eval translateObj $photosignal $::PHOTOSIGNAL_POSITION
    eval setEye $photosignal $::PHOTOSIGNAL_EYE
    return $photosignal
}
proc createAllObjects {} {
    # All graphics objects: ::flashattend::graphObjs
    # bkgd:        Stimulus background (vergence cues)
    set ::flashattend::graphObjs(bkgd) [makeBackground]
    # fix:         Fixation spot
    set ::flashattend::graphObjs(fix)  [makeFixation SPOT $::EYE_BOTH]
    # cue:         Attention cue (endogeneous or exogeneous)
    set ::flashattend::graphObjs(cue) \
        [makeCue $::trialPars::cuePos $::graphPars::cueSize \
            $::trialPars::cueType $::EYE_BOTH]
    # adaptors:    Adaptor targets
    set ::flashattend::graphObjs(adaptors) \
        [makeTargets $::trialPars::adaptColor $::trialPars::adaptOri \
            $::trialPars::adaptEye]
    # suppressors: Suppressor targets
    set ::flashattend::graphObjs(suppressors) \
        [makeTargets $::trialPars::supprColor $::trialPars::supprOri \
            $::trialPars::supprEye]
    # stim_adapts: Decremented contrast targets for adaptors
    set ::flashattend::graphObjs(stim_adapts) \
        [makeTargets $::trialPars::adaptColor $::trialPars::adaptOri \
            $::trialPars::adaptEye]
    if {$::trialPars::stimAdapt} {
        set stim [lindex $::flashattend::graphObjs(stim_adapts) \
            $::trialPars::stimIndex]
        changeTarget $stim $::trialPars::adaptColor $::trialPars::adaptOri \
            $::trialPars::stimChange
        if {$::USEPROBES} {
            convertTargetToProbe $stim \
                [lindex $::trialPars::targetLocs $::trialPars::stimIndex] \
                $::trialPars::adaptOri
        }
    }
    # stim_supps:  Decremented contrast targets for suppressors
    set ::flashattend::graphObjs(stim_supps) \
        [makeTargets $::trialPars::supprColor $::trialPars::supprOri \
            $::trialPars::supprEye]
    if {!$::trialPars::stimAdapt} {
        set stim [lindex $::flashattend::graphObjs(stim_supps) \
            $::trialPars::stimIndex]
        changeTarget $stim $::trialPars::supprColor $::trialPars::supprOri \
            $::trialPars::stimChange
        if {$::USEPROBES} {
            convertTargetToProbe $stim \
                [lindex $::trialPars::targetLocs $::trialPars::stimIndex] \
                $::trialPars::supprOri
        }
    }
    # err:         Yellow screen flash to indicate an error
    set ::flashattend::graphObjs(err) \
        [makeErrStim $::graphPars::errColor]
    # photosignal: 
    set ::flashattend::graphObjs(photosignal) [makePhotosignal]
}
proc quickAddObject {ob} {
    glistAddObjectsByLabel $::flashattend::graphObjs($ob) \
        $::flashattend::graphObjStates($ob)
}
proc addBkgdToGlist        {} { quickAddObject bkgd }
proc addFixToGlist         {} { quickAddObject fix  }
proc addPhotosignalToGlist {} { quickAddObject photosignal }
proc addCueToGlist         {} {
    if {$::trialPars::showCue} {
        quickAddObject cue
    }
}
proc addAdaptorsToGlist    {} {
    if {$::trialPars::brfs} {
        quickAddObject adaptors
    } else {
        glistAddObjectsByLabel $::flashattend::graphObjs(adaptors) \
            $::flashattend::graphObjStates(PAadaptors)
    }
}
proc addSuppressorsToGlist {} {
    #if {$::trialPars::stimAdapt} {
        quickAddObject suppressors
    #} else {
    #    set groupList $::flashattend::graphObjStates(suppressors)
    #    set stimStateIdx [lsearch $groupList change_on]
    #    set groupList [lreplace $groupList $stimStateIdx $stimStateIdx]
    #    glistAddObjectsByLabel $::flashattend::graphObjs(suppressors) $groupList
    #}
}
proc addStimToGlist {} {
#    glistAddObjectsByLabel $::flashattend::graphObjs(stim_adapts) \
#        $::flashattend::graphObjStates(stim)
#    glistAddObjectsByLabel $::flashattend::graphObjs(stim_supps) \
#        $::flashattend::graphObjStates(stim)

    if $::trialPars::stimAdapt {
        set stimList $::flashattend::graphObjs(stim_adapts)
    } else {
        set stimList $::flashattend::graphObjs(stim_supps)
    }
    set stim [lindex $stimList $::trialPars::stimIndex]
    glistAddObjectsByLabel $stim $::flashattend::graphObjStates(stim)
#    set frame 0
#    foreach stim $stimList {
#        glistAddObjectsByLabel $stim $::flashattend::graphObjStates(stim) $frame
#        incr frame
#    }
}
proc addErrToGlist {} {
    set errGroup [glistSlotID abort]
    # We will create the error stimulus as a two-frame animation, to produce a
    # simple flash of the yellow error screen followed by a blank screen.
    glistAddObject $::flashattend::graphObjs(err) $errGroup 0
    glistAddObject [nullObj] $errGroup 1 ;# Make frame 1 empty
    if {$::ANIMATION_WORKS} {
        # If STIM doesn't process the event loop properly, these animation-
        # related functions will not work, so we'll have to animate the error
        # stimulus manually. If it does work properly, however, using these
        # functions is preferable, as it doesn't require the RS_abort proc to
        # "hang" while animating the error stimulus.
        glistSetDynamic $errGroup 2 ;# Set time-based animation
        glistSetFrameTime $errGroup 0 0 ;# Frame 0 appears immediately
        glistSetFrameTime $errGroup 1 $::graphPars::errFlashTime
        glistSetRepeatMode $errGroup oneshot ;# Don't repeat the animation
    }
}

proc convertTargetToProbe {targ targPos targOri} {
    set probe [selectObjsByType $targ $::GOBJ_TYPE_ID(rivgrat)]
    set targetRadius [expr 0.5*$::graphPars::targetDiameter]
    set probeSize [expr $::graphPars::probeScale*$::graphPars::targetDiameter]
    scaleObj $probe $probeSize
    # Adjust number of grating cycles to maintain spatial frequency:
    set ncyc [expr $::graphPars::targetSpatialFreq*$probeSize]
    rivgrat_ncycles $probe $ncyc
    # The probe is (by necessity) a square, so its "radius" is a half-diagonal:
    set probeRadius [expr sqrt(2.)*$::graphPars::probeScale*$targetRadius]
    # Generate random position of probe within target, in polar coordinates:
    set probeRadOff [expr rand()*($targetRadius-$probeRadius)]
    set probeAzOff  [expr rand()*2.0*$::PI]
    # Convert to cartesian:
    set probeXOff [expr $probeRadOff*cos($probeAzOff)]
    set probeYOff [expr $probeRadOff*sin($probeAzOff)]
    # Get target coordinates:
    set targEcc [lindex $targPos 0]
    set targAz  [lindex $targPos 1]
    set targAzRad [expr $targAz*$::PI/180.]
    # Convert to Cartesian:
    set targX [expr $targEcc*cos($targAzRad)]
    set targY [expr $targEcc*sin($targAzRad)]
    # Get probe absolute coordinates:
    set probeX [expr $targX+$probeXOff]
    set probeY [expr $targY+$probeYOff]
    # Move probe:
    translateObj $probe $probeX $probeY
    # Problem: We need to be able to adjust the probe's phase as well, but
    # rivgrat provides us with no interface for doing so... We could try to
    # kludge something so that the grating-orientation direction position is
    # quantized to only phase-matched positions.  Our only other option would be
    # to modify the rivsines DLL.
}

