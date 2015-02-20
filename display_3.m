%display_3.m script
figure('PaperSize',[20.98404194812 29.67743169791],...
    'Color',[1 1 1]);
grid(axes,'on');
hold on
f2  = [mf2+2*(sf2),flipdim(mf2-2*(sf2),2)]';
h(1) = fill([xstar2, flipdim(xstar2,2)], f2, [6 6 6]/8, 'EdgeColor', [6 6 6]/8);
h(2) = plot(xstar2,mf2,'b-');
h(3) = plot(t,x,'k-','LineWidth',2); % Plot both signals.
h(4) = scatter(X2(1:60), y2(1:60), 'r','filled');

legend('Standard Deviation','Mean','GT','X^1')
set(legend,...
    'Position',[0.434313057085632 0.773798076923083 0.150347222222222 0.143990384615385]);
%xlabel('time (in seconds)');
ylim(gca,[-4 3]);
title('S^1','FontSize',14);
