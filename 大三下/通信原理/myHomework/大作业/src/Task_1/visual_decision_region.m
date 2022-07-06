function visual_decision_region(send_set, prob)
    rand_pts = -5+10*rand(1,2500)+1i*(-5+10*rand(1,2500)); % generate random points
    value = zeros(1,length(send_set));      % initialize values of the formula
    % SNR
    EsN0_dB = 18:0.4:20.4;                  % Es/N0,dB
    EsN0 = 10.^(EsN0_dB/10);                % Es/N0
    Es_avg = sum(abs(send_set).^2 .* prob); % Es
    N0 = Es_avg ./ EsN0;                    % N0
    % N0 = 1;
   
    for q = 1:length(N0)
        figure 
        for t = 1:length(rand_pts)
            for w = 1:length(send_set)
                value(w) = norm(rand_pts(t) - send_set(w))^2;  % distances
                value(w) = value(w)-N0(q)*log(prob(w));        % values of the formula
            end
            hold on
            pos = find(value == min(value));                   % classify and assign color
            if pos == 1
                h1 = plot(real(rand_pts(t)),imag(rand_pts(t)),'ro','Markersize',5);
            elseif pos == 2
                h2 = plot(real(rand_pts(t)),imag(rand_pts(t)),'go','Markersize',5);
            elseif pos == 3
                h3 = plot(real(rand_pts(t)),imag(rand_pts(t)),'bo','Markersize',5);
            elseif pos == 4
                h4 = plot(real(rand_pts(t)),imag(rand_pts(t)),'mo','Markersize',5);
            elseif pos == 5
                h5 = plot(real(rand_pts(t)),imag(rand_pts(t)),'g*','Markersize',5);
            elseif pos == 6
                h6 = plot(real(rand_pts(t)),imag(rand_pts(t)),'b*','Markersize',5);
            elseif pos == 7
                h7 = plot(real(rand_pts(t)),imag(rand_pts(t)),'m+','Markersize',5);
            elseif pos == 8
                h8 = plot(real(rand_pts(t)),imag(rand_pts(t)),'co','Markersize',5);
            end
        end
        ax = gca;
        ax.XAxisLocation = 'origin';   % set the intersection of 
        ax.YAxisLocation = 'origin';   % the axis to be the origin
        legend([h1(1),h2(1),h3(1),h4(1),h5(1),h6(1),h7(1),h8(1)],...
                'S1','S2','S3','S4','S5','S6','S7','S8') % legend
    end
end