% Root diagnostics file.
% Argument should be a plaintext file listing the qcr's to be loaded
% newFolder=$(date +%Y_%m_%d_%H_%M_%S)
function main_diagnostics(filePath)
    % Generate unique csv file
    [~,fMod] = system('(date +%Y_%m_%d_%H_%M_%S)');
    fName = ['diag_',strtrim(fMod),'.csv'];
    fOut = fopen(fName,'w');
    
    % Update this eventually...
    header = 'fname,nbchan,pnts,srate,manual,ch_s_sd-m,ch_s_sd_b-m,ch_s_sd_b-m-ch_sd_b,ch_s_sd_b-m-ic_sd1_b,ch_sd-m,ch_sd_b-m,ch_sd_b-m-ic_sd1_b,low_r-m,ic_sd1-m,ic_sd1_b-m,ic_sd2,ch_s_sd,ch_sd,low_r,bridge,LtModelMean,LtModelStd,Lt_quant_0.05,Lt_quant_0.15,Lt_quant_0.25,Lt_quant_0.5,Lt_quant_0.75,Lt_quant_0.85,Lt_quant_0.95,manual_comp_1,ic_rt_1,linkpvaluesMean,linkpvaluesStd,lpv_quant_0.05,lpv_quant_0.15,lpv_quant_0.25,lpv_quant_0.5,lpv_quant_0.75,lpv_quant_0.85,lpv_quant_0.95';
    fprintf(fOut,'%s\n',header);
    
    % Read line by line of the specified diag list
    fIn = fopen(filePath,'r');
    tline = fgetl(fIn);
    while ischar(tline)
        single_diagnostic(fOut,tline);
        tline = fgetl(fIn);
    end
    
    % Proper form!
    fclose(fIn);
    fclose(fOut);
end