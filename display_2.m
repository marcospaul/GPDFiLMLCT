%display_2.m
figure('PaperSize',[20.98404194812 29.67743169791],...
    'Color',[1 1 1]);
    grid(axes,'on');
    hold on
plot(t,x,'k-','LineWidth',2) % Plot both signals.
scatter(t(s2),y2,'r','filled')
scatter(t(s3),y3,'g','filled')
title('Training Data','FontSize',14);
%xlabel('time (in seconds)');
legend('GT','X^1','X^2');
set(legend,...
    'Position',[0.434313057085632 0.773798076923083 0.150347222222222 0.143990384615385]);
ylim(gca,[-4 3]); 
% Create xlabel
    xlabel('Angle');
    % Create ylabel
    ylabel('Range');