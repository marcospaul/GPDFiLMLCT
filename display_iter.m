%display_iter.m
figure('PaperSize',[20.98404194812 29.67743169791],...
        'Color',[1 1 1]);
    grid(axes,'on');
    hold on
    f_updated  = [mf_updated+2*(sf_updated),flipdim(mf_updated-2*(sf_updated),2)]';
    h(1) = fill([xstar2, flipdim(xstar2,2)], f_updated, [6 6 6]/8, 'EdgeColor', [6 6 6]/8);
    h(2) = plot(xstar2,mf_updated,'b-');
    h(3) = plot(t,x,'k-','LineWidth',2); % Plot both signals.
    h(4) = scatter(X_test(p), y_test(p), 'r','filled');
    h(5) = scatter(X2, y2, 'b','filled');
    h(6) = scatter(X_consistent, y_consistent, 'g','filled');
    h(7) = scatter(X_inconsistent, y_inconsistent, 'm','filled');
    
    hold on
    message_iter=sprintf('Iter: %d',p)
    
    annotation('textbox',...
    [0.664310954063604 0.862275449101795 0.108903331650682 0.0531650983746794],...
    'String',{message_iter},...
    'FontWeight','bold',...
    'FitBoxToText','off',...
    'BackgroundColor',[0.972549021244049 0.972549021244049 0.972549021244049]);
    
   

    legend('Standard Deviation','Mean','GT','X^{test}','X^j','X^{consistent}','X^{inconsistent}')
    set(legend,...
        'Position',[0.434313057085632 0.773798076923083 0.150347222222222 0.143990384615385]);
    %xlabel('time (in seconds)');
    ylim(gca,[-4 3]);
    title('S^1','FontSize',14);