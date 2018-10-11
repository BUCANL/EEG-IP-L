% Root diagnostics file.
% Argument should be a plaintext file listing the qcr's to be loaded
% newFolder=$(date +%Y_%m_%d_%H_%M_%S)
function main_diagnostics(filePath)
    % Generate unique csv file
    [~,fMod] = system('(date +%Y_%m_%d_%H_%M_%S)');
    fName = ['diag_',strtrim(fMod),'.csv'];
    fOut = fopen(fName,'w');
    
    % Update this eventually...
    header = 'fname,nbchan,pnts,srate,manual,ch_s_sd-m,ch_s_sd_b-m,ch_s_sd_b-m-ch_sd_b,ch_s_sd_b-m-ic_sd1_b,ch_sd-m,ch_sd_b-m,ch_sd_b-m-ic_sd1_b,low_r-m,ic_sd1-m,ic_sd1_b-m,ic_sd2,ch_s_sd,ch_sd,low_r,bridge,LtModelMean,LtModelStd,quant_0.05,quant_0.15,quant_0.25,quant_0.5,quant_0.75,quant_0.85,quant_0.95,pre_qc_comp';
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