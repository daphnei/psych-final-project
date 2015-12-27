function [] = process_data() 
    [gammas_1, fractions_correct_1] = read_data('C:\Users\charles\Documents\Daphne\psych-final-project\data\test\GammaThreshold\Marissa\**\*.csv');
    [gammas_2, fractions_correct_2] = read_data('C:\Users\charles\Documents\Daphne\psych-final-project\data\test\GammaThreshold\daphne\**\*.csv');
    
    close all;
    figure();
    plot(gammas_1, fractions_correct_1, 'o');
    hold on;
    plot(gammas_2, fractions_correct_2, 'o');
    
    xlabel('Gamma Adjustment');
    ylabel('Fraction of trials identified correctly');
    legend('Marissa', 'Daphne');
    
    [fitresult_1, gof_1, gamma_difs_1, lower_fractions_1] = ...
        fit_psychometric_on_lower(gammas_1, fractions_correct_1);
    [fitresult_2, gof_2, gamma_difs_2, lower_fractions_2] = ...
        fit_psychometric_on_lower(gammas_2, fractions_correct_2);
 
    figure();
    hold on;
    
    h1 = plot(fitresult_1, gamma_difs_1, lower_fractions_1, 'bo');
    h2 = plot(fitresult_2, gamma_difs_2, lower_fractions_2, 'go');
    
    legend([h1(1), h2(1), h2(2)], ...
        'Subject 1 data', 'Subject 2 data', 'Fitted curves', ...
        'Location', 'southwest'); 
    
    title('Threshold for Discerning Unmodified Image from Image with Lowered Gamma');
    xlabel('Gamma correction (amount below 2.2)');
    ylabel('Fraction of trials identified correctly');
end

function [fitresult, gof, gamma_differences, fractions_correct] = fit_psychometric_on_lower(gamma_values, fractions_correct) 
    acceptable_indices = find(gamma_values < 2.2);
    gamma_values = gamma_values(acceptable_indices);
    fractions_correct = fractions_correct(acceptable_indices);
    
    % Instead of having gamma values where a smaller value means easier
    % threshold, represent the values as difference from 2.2.
    gamma_differences = 2.2 - gamma_values;
    
    % I am using the instructions found on 
    % http://davehunter.wp.st-andrews.ac.uk/2015/04/12/fitting-a-psychometric-function/+
    ft = fittype( '0.5+(1-0.5-l)./(1+exp(-(x-alpha)/beta))', 'independent', 'x', 'dependent', 'y' );
    opts = fitoptions( ft );    
    opts.Display = 'Off';    
    opts.Lower = [-Inf 0 0];    
    opts.StartPoint = [0.132903481469417 0.762038603323984 0];    
    opts.Upper = [Inf 1 1];

    [fitresult, gof] = fit( gamma_differences, fractions_correct, ft, opts );
end

function [possible_gamma_values, fractions_correct] = read_data(folder)
    csvs = rdir(folder);
    
    all_data = [];
    for i = 1:size(csvs, 1)
       file = csvread(csvs(i).name, 1, 0);
       all_data = [all_data; file];
    end

    % Find the fraction of trials identified correctly for each of the possible
    % gamma values.
    possible_gamma_values = unique(all_data(:, 1));
    fractions_correct = zeros(size(possible_gamma_values));
    for i = 1:size(possible_gamma_values, 1)
        gamma_value = possible_gamma_values(i);

        data_with_this_gamma_value = all_data(all_data(:, 1) == gamma_value,:);
        fractions_correct(i) = sum(data_with_this_gamma_value(:, 3) > 0) / ...
            size(data_with_this_gamma_value, 1);
    end
end


