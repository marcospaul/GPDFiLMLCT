%display_4.m script
[mf3, vf3] = GP2.query(xstar3);
sf3  = sqrt(vf3);
figure('PaperSize',[20.98404194812 29.67743169791],...
    'Color',[1 1 1]);
grid(axes,'on');
hold on
f3  = [mf3+2*(sf3),flipdim(mf3-2*(sf3),2)]';
h(1) = fill([xstar3, flipdim(xstar3,2)], f3, [6 6 6]/8, 'EdgeColor', [6 6 6]/8);
h(2) = plot(xstar3,mf3,'b-');
h(3) = plot(t,x,'k-','LineWidth',2); % Plot both signals.
h(4) = scatter(X3(1:60), y3(1:60), 'g','filled');
%legend(h,'Predictive Standard Deviation','Predictive Mean','GT','Training Points')
legend('Standard Deviation','Mean','GT','S^2')
set(legend,...
    'Position',[0.434313057085632 0.773798076923083 0.150347222222222 0.143990384615385]);
ylim(gca,[-4 3]);
title('S^2','FontSize',14);
hold on
