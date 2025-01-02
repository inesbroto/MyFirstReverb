function [output] = multi_channel_diffusion(input,sr, nbr_ch,max_delay_ms,ch_inversion, hadamard_matrix)
input_size = size(input);

%% assertions and control
if input_size(2)<nbr_ch
    fprintf('Extending channels: %g to %g',[input_size(2) nbr_ch])
    mult_factor = ceil(nbr_ch/input_size(2));
    input = repmat(input, 1, mult_factor);
end
if input_size(2)>nbr_ch
    sprintf('More input channels than expected. Only first %g (from %g) will be used', [nbr_ch input_size(2)])
end
assert(size(ch_inversion,1)==nbr_ch,sprintf('Size of ch_inversion (%g) needs to be nbr_ch (%g)', [size(ch_inversion,1) nbr_ch]))
%% algorithm
delaySamples = rand(nbr_ch,1)/nbr_ch + (0:nbr_ch-1)'/nbr_ch; %create random points between 0 and 1 equally spaced among channels
delaySamples = ceil(delaySamples*max_delay_ms*0.001*sr); %scale to max_delay, converse to seconds and then to samples
input = vertcat(input,zeros(max(delaySamples), nbr_ch));
output = zeros(size(input));
for i = 1:size(output,1)
    delayed = zeros(1, nbr_ch);
    for ch = 1:nbr_ch
        if i > delaySamples(ch)
            delayed(ch) = input(i-delaySamples(ch),ch)*ch_inversion(ch);
        end
    end
    output(i,:) = delayed*hadamard_matrix./sqrt(nbr_ch);
end
return




