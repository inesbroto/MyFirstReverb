function [output] = multi_channel_delay(input,sr, nbr_ch,delay_ms,delayGain)

input_size = size(input);

%% Assertions
if input_size(2)<nbr_ch %it's avoided for the sake of memory consumption.
    fprintf('Extending channels: %g to %g',[input_size(2) nbr_ch])
    mult_factor = ceil(nbr_ch/input_size(2));
    input = repmat(input, 1, mult_factor);
end
if input_size(2)>nbr_ch
    sprintf('More input channels than expected. Only first %g (from %g) will be used', [nbr_ch input_size(2)])
end
assert(size(delay_ms,1)==nbr_ch, sprintf('Size of delay_ms (%g) needs to be nbr_ch (%g)', [size(delay_ms,1) nbr_ch]))
assert(size(delayGain,1)==nbr_ch,sprintf('Size of delayGain (%g) needs to be nbr_ch (%g)', [size(delayGain,1) nbr_ch]))
%% Algorithm
delaySamples = ceil(delay_ms*0.001*sr);% converse to seconds and then to samples

input = vertcat(input,zeros(max(delaySamples), nbr_ch));
output = zeros(size(input));
for i = 1:size(output,1)
    for ch = 1:nbr_ch
        if i > delaySamples(ch)
            output(i,ch) = input(i-delaySamples(ch),ch)*delayGain(ch);
        end
    end
end
return


%might be adding some extra channels because of the ceil of mult_factor.


