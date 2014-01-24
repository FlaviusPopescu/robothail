function [] = showTime()
	
	load ('expdata.mat');
	
	hold on;
	f= figure(1);
	xlabel('Time [ms]');
	ylabel('No. of tasks completed');
	% plot(n11, [1:length(n11)], 'r-');
	% plot(n12, [1:length(n12)], 'r-');
	% plot(n13, [1:length(n13)], 'r-');
	% plot(n14, [1:length(n14)], 'r-');
	% plot(n15, [1:length(n15)], 'r-');
	% legend('Single Robot');

	
	n1avg = getAvg(n11, n12, n13, n14, n15);
	plot(n1avg, [1:length(n1avg)], 'c');
	% 
	% plot(n21, [1:length(n21)], 'g-');
	% plot(n22, [1:length(n22)], 'g-');
	% plot(n23, [1:length(n23)], 'g-');
	% plot(n24, [1:length(n24)], 'g-');
	% plot(n25, [1:length(n25)], 'g-');
	% legend('Team of 2 robots');
	% 
	n2avg = getAvg(n21, n22, n23, n24, n25);
	plot(n2avg, [1:length(n2avg)], 'm');
	% % 
	% % 
	% plot(n31, [1:length(n31)], 'b-');
	% plot(n32, [1:length(n32)], 'b-');
	% plot(n33, [1:length(n33)], 'b-');
	% plot(n34, [1:length(n34)], 'b-');
	% plot(n35, [1:length(n35)], 'b-');
	% legend('Team of 3 robots');
	% 
	n3avg = getAvg(n31, n32, n33, n34, n35);
	plot(n3avg, [1:length(n3avg)], 'r');

	% % 
	% plot(n41, [1:length(n41)], 'm-');
	% plot(n42, [1:length(n42)], 'm-');
	% plot(n43, [1:length(n43)], 'm-');
	% plot(n44, [1:length(n44)], 'm-');
	% plot(n45, [1:length(n45)], 'm-');
	% legend('Team of 4 robots');


	n4avg = getAvg(n41, n42, n43, n44, n45);
	plot(n4avg, [1:length(n4avg)], 'k');

	legend('Single Robot', 'Team of 2 robots', 'Team of 3 robots','Team of 4 robots');
	
	
end