classdef multipleDelayPlugin < audioPlugin
    properties
        Gain = [0.8, 0.2, 0.5, 0.3];
        NbrCh=4;
    end
    properties (Constant)
        PluginInterface = audioPluginInterface(...
            audioPluginParameter('Gain',...
            'DisplayName','Echo Gain',...
            'Mapping',{'lin',0,2}))
    end
    properties(Access=private)
        CircularBuffer = zeros(192001,4); % buffer len * number of channels
        BufferIndex = 1; 
        delaySamples=[2205, 2893, 3084, 4055];
    end
    methods
        function out = process(plugin, in)
            input_size = size(in);
            
            out = zeros(input_size); 
            mult_factor = ceil(plugin.NbrCh/input_size(2));
            
            ext_in = repmat(in, 1, mult_factor);  %for multiple channels, not sure I'll use it          
            ext_out = zeros(size(ext_in));   % for multiple channels                           
            sprintf('input size - samples=%g channels=%g', [input_size(1), input_size(2)])
            sprintf('extended size - samples=%g channels=%g', [size(ext_out,1), size(ext_out,2)])

            writeIndex = plugin.BufferIndex;                    
            
            readIndex = repmat(writeIndex, plugin.NbrCh,1)' - plugin.delaySamples;   
            readIndex(readIndex <= 0) = readIndex(readIndex <= 0) + 192001; %make sure all the pointers are positive numbers

            for i = 1:input_size(1)
                %plugin.CircularBuffer(writeIndex,:) = in(i,:);
                for ch = 1:plugin.NbrCh
                    delayed = plugin.CircularBuffer(readIndex(ch),ch);      
                    ext_out(i,ch) = ext_in(i,ch) + delayed * plugin.Gain(ch);        
                    %plugin.CircularBuffer(writeIndex,ch) = ext_in(i,ch) + delayed * plugin.Gain(ch);  %ext_out(i,ch)
                end
                plugin.CircularBuffer(writeIndex,:) = ext_out(i,:); %HERE I should add the household matrix transformation. Check https://es.mathworks.com/matlabcentral/answers/763151-qr-factorization-using-householder-transformation

                out(i,:) = repmat(sum(plugin.CircularBuffer(writeIndex),2)/plugin.NbrCh, 1, 2);        
                writeIndex = writeIndex + 1; 
                writeIndex(writeIndex > 192001) = 1; %reset pointer if it has reached the end    

                readIndex = readIndex + 1; 
                readIndex(readIndex > 192001) = 1; %reset pointer if it has reached the end
                             
            end                                                 
            plugin.BufferIndex = writeIndex;                    
        end
    end
end