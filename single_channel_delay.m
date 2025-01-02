function [output] = single_channel_delay(input,sr, delay_ms, delayGain)
delaySamples = ceil(delay_ms*0.001*sr);% converse to seconds and then to samples

output = input;
for i = 1:size(input,1)
    if (i <= delaySamples)
        output(i) = output(i);
    else
        output(i) = output(i)+output(i-delaySamples)*delayGain;
    end
end

return

%%
