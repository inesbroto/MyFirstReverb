function [output] = multi_channel_mixed_FMODDL(input,sr, nbr_ch,delay_ms,delayGain, amod, fmod)
%FDL stands for Feedback Delay Loop
input_size = size(input);

%% Assertions
%if input_size(2)<nbr_ch %it's avoided for the sake of memory consumption
%    fprintf('Extending channels: %g to %g',[input_size(2) nbr_ch])
%    mult_factor = ceil(nbr_ch/input_size(2));
%    input = repmat(input, 1, mult_factor);
%end
if input_size(2)>nbr_ch
    sprintf('More input channels than expected. Only first %g (from %g) will be used', [nbr_ch input_size(2)])
end
assert(size(delay_ms,1)==nbr_ch, sprintf('Size of delay_ms (%g) needs to be nbr_ch (%g)', [size(delay_ms,1) nbr_ch]))
assert(size(delayGain,1)==nbr_ch,sprintf('Size of delayGain (%g) needs to be nbr_ch (%g)', [size(delayGain,1) nbr_ch]))
%% Algorithm

delaySamples = ceil(delay_ms*0.001*sr);% converse to seconds and then to sample

mult_factor = ceil(nbr_ch/input_size(2));
input = vertcat(input,repmat(zeros(1, nbr_ch), 200000, 1));
output = repmat(input, 1, mult_factor);

modulator = amod*cos(2*pi*fmod*[0:size(input,1)]/sr)'/2 + 0.5;


for i = 1:size(input,1)
    delayed = zeros(1, nbr_ch);
    for ch = 1:nbr_ch
        if i>delaySamples(ch)
            %%dubte!! què és un modulated delay? check script
            %%multi_channel_MODdiffusion for logic details
            %% logic 1
            %frac_delay = delaySamples(ch)*modulator(i);
            %interpolated_sample = (1-modulator(i))*output(i-floor(frac_delay),ch)+modulator(i)*output(i-ceil(frac_delay),ch);

            %% logic 2 !! NEEDS i > delaySamples(ch) +1
            if i> delaySamples(ch)+1
                interpolated_sample = (1-modulator(i))*output(i-delaySamples(ch)-1,ch)+modulator(i)*output(i-delaySamples(ch),ch);
                delayed(ch) =interpolated_sample*delayGain(ch); %mod(ch,2)+1 modulo is usully an expensive function

            end
            %% if logic 2, solve issue with i indexing (next line before the if ending)
            %delayed(ch) = interpolated_sample*delayGain(ch);
        end
    end
    output(i,:) = output(i,:) + orthogonal_mixing(delayed);
end
return



