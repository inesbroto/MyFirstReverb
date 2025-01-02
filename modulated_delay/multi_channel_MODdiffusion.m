function [output] = multi_channel_MODdiffusion(input,sr, nbr_ch,max_delay_ms,ch_inversion, hadamard_matrix, amod, fmod)
%to do documentation
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

modulator = amod*cos(2*pi*fmod*[0:size(input,1)]/sr)';%/2 + 0.5;
input_size = size(input);
for i = 1:size(output,1)
    delayed = zeros(1, nbr_ch);
    for ch = 1:nbr_ch
        if i > delaySamples(ch)
            %%dubte!! un modulated delay es:
            % 1-> multilplicar delay_samples pel modulador, i interpolar
            % entre els dos valors enters (canvis de delay times bastant
            % grans [0,delay_time]
            % 2-> sumar el valor del modulador als samples i interpolar
            % sempre entre delay_time i delay_time+1 pero amb diferents
            % pesos
            % 3-> el delay es el delay mes el modulador*sr. Això serà
            % fraccionari. cal interpolar.
            % 4-> amod es la longitud máxima (en ms) del modulador de delay,
            % amod*modulator es el que s'afegeix al delay en qüestió. i
            % després s'interpola
            %
            % CREC que és el 4
            %% logic 1
            %frac_delay = delaySamples(ch)*modulator(i);
            %interpolated_sample = (1-modulator(i))*input(i-floor(frac_delay),ch)+modulator(i)*input(i-ceil(frac_delay),ch);
            %delayed(ch) =interpolated_sample*ch_inversion(ch); %mod(ch,2)+1 modulo is usully an expensive function

            %% logic 2 !! NEEDS i > delaySamples(ch) +1
            %if i> delaySamples(ch)+1
            %    interpolated_sample = (1-modulator(i))*input(i-delaySamples(ch)-1,ch)+modulator(i)*input(i-delaySamples(ch),ch);
            %    delayed(ch) =interpolated_sample*ch_inversion(ch); %mod(ch,2)+1 modulo is usully an expensive function
            %end
            %% logic 3
            %frac_delay =  modulator(i)*sr;
            %if i>delaySamples(ch)+ceil(frac_delay)
            %    floor_weigth = frac_delay - floor(frac_delay);
            %    interpolated_sample = floor_weigth*input(i-delaySamples(ch)-floor(frac_delay),ch)+(1-floor_weigth)*input(i-delaySamples(ch)-ceil(frac_delay),ch);
            %    delayed(ch) =interpolated_sample*ch_inversion(ch); %mod(ch,2)+1 modulo is usully an expensive function
            %end
            %% logic 4
            if i > delaySamples(ch)+max(modulator(i))*0.001*sr%ch ==3
                frac_delay = delaySamples(ch) + modulator(i)*0.001*sr;
                upper_sample_idx = i + ceil(frac_delay);
                lower_sample_idx = i - floor(frac_delay);
    
                if i - floor(frac_delay)>0 && i + ceil(frac_delay)<input_size(1)%
                    %disp(i-delaySamples(ch)-floor(frac_delay))
                    floor_weigth = frac_delay - floor(frac_delay);
                    interpolated_sample = floor_weigth*input(lower_sample_idx,ch)+(1-floor_weigth)*input(upper_sample_idx,ch);
                    delayed(ch) =interpolated_sample*ch_inversion(ch); %mod(ch,2)+1 modulo is usully an expensive function
                end
            else
                delayed(ch) = input(i-delaySamples(ch),ch)*ch_inversion(ch);

            end

            %% if logic 2 or 3, solve issue with i indexing (next line before the if ending)
            %delayed(ch) =interpolated_sample*ch_inversion(ch); %mod(ch,2)+1 modulo is usully an expensive function
        end
    end
    output(i,:) = delayed*hadamard_matrix./sqrt(nbr_ch);
end
return


%might be adding some extra channels because of the ceil of mult_factor.
%check


