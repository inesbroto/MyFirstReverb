classdef myEchoPlugin < audioPlugin
    properties
        Gain = 0.3;
    end
    properties (Constant)
        PluginInterface = audioPluginInterface(...
            audioPluginParameter('Gain',...
            'DisplayName','Echo Gain',...
            'Mapping',{'lin',0,2}))
    end

    properties(Access=private)
        CircularBuffer = zeros(192001,2);
        BufferIndex = 1; 
        NSamples=2205;
    end
    methods
        function out = process(plugin, in)
            out = zeros(size(in));                              
            writeIndex = plugin.BufferIndex;                    
            readIndex = writeIndex - plugin.NSamples;           
            if readIndex <= 0                                   
                readIndex = readIndex + 192001;                 
            end                                                 
                                                                
            for i = 1:size(in,1)                                
                plugin.CircularBuffer(writeIndex,:) = in(i,:);  
                                                                
                delayed = plugin.CircularBuffer(readIndex,:);      
                out(i,:) = in(i,:) + delayed * plugin.Gain;        

                writeIndex = writeIndex + 1;                    
                if writeIndex > 192001                          
                    writeIndex = 1;                             
                end                                             
                                                                
                readIndex = readIndex + 1;                      
                if readIndex > 192001                           
                    readIndex = 1;                              
                end                                             
            end                                                 
            plugin.BufferIndex = writeIndex;                    
        end
    end
end