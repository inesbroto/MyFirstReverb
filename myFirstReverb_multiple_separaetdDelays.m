function [output] = myFirstReverb(input, sr, nbr_ch, nbr_diff, diff_delays,separate_delay_path, fb_delays, fb_gains,static_filter_freq)
%UNTITLED Summary of this function goes here
    %   Detailed explanation goes here
    output=input;
    separated_delay = zeros(size(output,1),2);
    for i = 1:nbr_diff
        output = multi_channel_diffusion(output, sr, nbr_ch, diff_delays(i),(2 * (rand(nbr_ch, 1) > 0.5) - 1), hadamard(nbr_ch));
        if separate_delay_path==1
            delayed_signal = multi_channel_delay(output(:,1:2), sr,2,[29, 61]',[1,1]');
            separated_delay = vertcat(separated_delay, zeros(size(delayed_signal,1)-size(separated_delay,1)))+delayed_signal; %allocate space first for efficiency
        end
    end
    output = multi_channel_mixed_FDL(output, sr,nbr_ch,fb_delays, fb_gains);
    output = output(:,1:2)+vertcat(separated_delay, zeros(size(output,1)-size(separated_delay,1)));

    if isfloat(static_filter_freq) | isinteger(static_filter_freq)
        output = lowpass(output,static_filter_freq,sr);
    end

end