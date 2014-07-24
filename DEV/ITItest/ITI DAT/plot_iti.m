function plot_iti(data)

figure;
scatter(data(:,end),data(:,3)); hold all
grpstats(data(:,3),data(:,end),0.05);
