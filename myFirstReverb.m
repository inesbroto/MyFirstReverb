function [output] = myFirstReverb(input, sr, nbr_ch, reverb_pct, nbr_diff, diff_delays, fb_delays, fb_gains,early_reflections_pct,static_filter_freq)
%UNTITLED Summary of this function goes here
    %   Detailed explanation goes here
    output=input;
    for i = 1:nbr_diff
        output = multi_channel_diffusion(output, sr, nbr_ch, diff_delays(i),(2 * (rand(nbr_ch, 1) > 0.5) - 1), hadamard(nbr_ch));
    end


    delayed = multi_channel_delay(output(:,1:2), sr,2,[7, 13]',[1, 1]');
    output = multi_channel_mixed_FDL(output, sr,nbr_ch,fb_delays, fb_gains);

    delayed = vertcat(delayed, zeros(size(output,1)-size(delayed,1),2));
    output = early_reflections_pct*delayed + (1-early_reflections_pct)*output(:,1:2);

    if isfloat(static_filter_freq) | isinteger(static_filter_freq)
        output = lowpass(output,static_filter_freq,sr);
    end
    output = (1-reverb_pct)*vertcat(input, zeros(size(output,1)-size(input,1),2))+reverb_pct*output;  
end