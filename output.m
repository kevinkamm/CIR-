function output(fileName,...
                marketTimes,marketDF,marketZeroRates,...
                paramFmin,modelParam,...
                ctimes,MREs,params,...
                dt,M,...
                errGa,errFmin,meanRelL1Err,meanRelL2Err,dfMeanErr,...
                ctimeGa,ctimeFmin,ctimeSim,...
                zcFigures,dfFigures,rFigures,mvFigures,fFigures,...
                maturitySwap,tenorSwap,errorSwap,marketSwapPrice,strikeSwap)

temp=split(fileName,'_');
yearStr=temp(end);
yearStr=yearStr{1};
year=str2num(yearStr(1:4));
month=str2num(yearStr(5:6));
day=str2num(yearStr(7:end));
switch yearStr
    case '20191230'
        identifier='A';
    case '20201130'
        identifier='B';
    otherwise
        identifier='Z';
end
            
picType='eps';
saveParam='epsc';

root=[pwd, '\' ,'Results'];
pdfRoot=[root,'\','Pdf'];
tempPath=[pdfRoot,'\','temp'];
copyPath=[pdfRoot,'\',fileName];
templatePath=[tempPath,'\','template', '.','tex'];
outputFilePath=[copyPath,'\','template','.','pdf';...
            copyPath,'\','template','.','tex'];
copyFilePath=[copyPath,'\',fileName,'.','pdf';...
              copyPath,'\',fileName,'.','tex'];
inputPath=[tempPath,'\','input','.','tex'];
          
mkDir(pdfRoot);
% delDir(tempPath);
mkDir(tempPath);
cleanDir(tempPath,{'template.tex'});
delDir(copyPath)
mkDir(copyPath)
delFile(inputPath);

inputFile=fopen(inputPath,'a');
% Head
fprintf(inputFile,...
        '\\section{CIR- model}\n');
% Calibration Parameters
fprintf(inputFile,...
        '\\subsection{Calibration Parameters}\n');
[latexFilePath,latexCommand]=saveCIRParameters('CIRParam');
fprintf(inputFile,...
        '\t\\input{%s}\n',changeSlash(latexFilePath));
for iLC=1:1:size(latexCommand,1)
    fprintf(inputFile,...
            '\t%s\\hfill\\\\\n',latexCommand(iLC,:));
end
% Model Paramters
fprintf(inputFile,...
        '\\subsection{Model Parameters}\n');
[latexFilePath,latexCommand]=saveModelParameters('ModelParam');
fprintf(inputFile,...
        '\t\\input{%s}\n',changeSlash(latexFilePath));
for iLC=1:1:size(latexCommand,1)
    fprintf(inputFile,...
            '\t%s\n',latexCommand(iLC,:));
end
% Euler Parameter
fprintf(inputFile,...
        '\\subsection{Euler Parameter}\n');
[latexFilePath,latexCommand]=saveEulerParam('Euler');
fprintf(inputFile,...
        '\t\\input{%s}\n',changeSlash(latexFilePath));
fprintf(inputFile,...
        '\t%s\n',latexCommand);
% Computational times
fprintf(inputFile,...
        '\\subsection{Computational Times}\n');
[latexFilePath,latexCommand]=saveCompTimes('CompTimes');
fprintf(inputFile,...
        '\t\\input{%s}\n',changeSlash(latexFilePath));
fprintf(inputFile,...
        '\t%s\n\\hfill\\\\\n',latexCommand);
if ~isempty(params)
    [latexFilePath,latexCommand]=saveCalibrationTimes('CompTimes');
    fprintf(inputFile,...
            '\t\\input{%s}\n',changeSlash(latexFilePath));
    fprintf(inputFile,...
            '\t%s\n',latexCommand);
end
% Mean errors of DF
[latexFilePath,latexCommand]=saveDFMeanErr('DF');
fprintf(inputFile,...
        '\\subsection{Mean errors of Discount Factor}\n');
fprintf(inputFile,...
        '\t\\input{%s}\n',changeSlash(latexFilePath));
fprintf(inputFile,...
        '\\begin{table}\n');
fprintf(inputFile,...
        '\t%s\n',latexCommand);
fprintf(inputFile,...
        '\\centering\n');
fprintf(inputFile,...
        '\\caption{Market data containing the zero rate curve and zero coupon curve at %d/%d/%d.}\n',day,month,year);
fprintf(inputFile,...
        '\\label{tab:market_data%s}\n',identifier);
fprintf(inputFile,...
        '\\end{table}\n');
% Error Swaption
[latexFilePath,latexCommand]=saveErrorSwaption('Swaption');
fprintf(inputFile,...
        '\\subsection{Errors of Swaption}\n');
fprintf(inputFile,...
        '\t\\input{%s}\n',changeSlash(latexFilePath));
fprintf(inputFile,...
        '\\begin{table}\n');
fprintf(inputFile,...
        '\t%s\n',latexCommand);
fprintf(inputFile,...
        '\\centering\n');
fprintf(inputFile,...
        '\\caption{Swaption error for data at %d/%d/%d.}\n',day,month,year);
fprintf(inputFile,...
        '\\label{tab:swaption_error%s}\n',identifier);
fprintf(inputFile,...
        '\\end{table}\n');
% Plots of ZC Prices
fprintf(inputFile,...
        '\\subsection{Plots of Zero Coupon Prices}\n');
latexFilePath=saveFigures(zcFigures,'ZC',['ZC','_',identifier]);
fprintf(inputFile,...
        '\t\\input{%s}\n',changeSlash(latexFilePath));
% Plots of DF
fprintf(inputFile,...
        '\\subsection{Plots of Discount Factor}\n');
latexFilePath=saveFigures(dfFigures,'DF',['DF','_',identifier]);
fprintf(inputFile,...
        '\t\\input{%s}\n',changeSlash(latexFilePath));
% Plots of Interest rates
fprintf(inputFile,...
        '\\subsection{Plots of Interest Rates}\n');
latexFilePath=saveFigures(rFigures,'Rates',['R','_',identifier]);
fprintf(inputFile,...
        '\t\\input{%s}\n',changeSlash(latexFilePath));
% Plots theoretical mean and variance
fprintf(inputFile,...
        '\\subsection{Plots of theoretical Mean and Variance}\n');
latexFilePath=saveFigures(mvFigures,'MeanVar',['MV','_',identifier]);
fprintf(inputFile,...
        '\t\\input{%s}\n',changeSlash(latexFilePath));
% Plots of Forward Curves
fprintf(inputFile,...
        '\\subsection{Plots of Forward Zero-Coupon Prices}\n');
latexFilePath=saveFigures(fFigures,'Forward',['F','_',identifier]);
fprintf(inputFile,...
        '\t\\input{%s}\n',changeSlash(latexFilePath));
% % Plots of Forward Zero-Coupon Prices
% fprintf(inputFile,...
%         '\\subsection{Plots of Forward Zero-Coupon Prices}\n');
% latexFilePath=saveFigures(pFigures,'ForwardZCPrices',['FZCP','_',identifier]);
% fprintf(inputFile,...
%         '\t\\input{%s}\n',changeSlash(latexFilePath));
% Appendix
fprintf(inputFile,...
        '\\appendix\n');
% Market Data
% Zero Coupon Curve
fprintf(inputFile,...
        '\\section{Market Data}\n');
[latexFilePath,latexCommand]=saveMarketData('MarketData');
fprintf(inputFile,...
        '\t\\input{%s}\n',changeSlash(latexFilePath));
fprintf(inputFile,...
        '\\begin{table}\n');
fprintf(inputFile,...
        '\t%s\n',latexCommand);
fprintf(inputFile,...
        '\\centering\n');
fprintf(inputFile,...
        '\\caption{Market data containing the zero rate curve and zero coupon curve at %d/%d/%d.}\n',day,month,year);
fprintf(inputFile,...
        '\\label{tab:market_data%s}\n',identifier);
fprintf(inputFile,...
        '\\end{table}\n');
% Market Data
fprintf(inputFile,...
        '\\section{Market Data}\n');
[latexFilePath,latexCommand]=saveStrikeSwaption('MarketData');
fprintf(inputFile,...
        '\t\\input{%s}\n',changeSlash(latexFilePath));
fprintf(inputFile,...
        '\\begin{table}\n');
fprintf(inputFile,...
        '\t%s\n',latexCommand);
fprintf(inputFile,...
        '\\centering\n');
fprintf(inputFile,...
        '\\caption{Market data containing the swaption strikes at %d/%d/%d.}\n',day,month,year);
fprintf(inputFile,...
        '\\label{tab:strike_swaption%s}\n',identifier);
fprintf(inputFile,...
        '\\end{table}\n');
% Market Data
fprintf(inputFile,...
        '\\section{Market Data}\n');
[latexFilePath,latexCommand]=saveMarketSwaption('MarketData');
fprintf(inputFile,...
        '\t\\input{%s}\n',changeSlash(latexFilePath));
fprintf(inputFile,...
        '\\begin{table}\n');
fprintf(inputFile,...
        '\t%s\n',latexCommand);
fprintf(inputFile,...
        '\\centering\n');
fprintf(inputFile,...
        '\\caption{Market data containing the swaption prices at %d/%d/%d.}\n',day,month,year);
fprintf(inputFile,...
        '\\label{tab:market_swaption%s}\n',identifier);
fprintf(inputFile,...
        '\\end{table}\n');
fclose(inputFile);
% Compile Latex
currFolder=cd(tempPath);
str1=sprintf('pdflatex %s',templatePath);
system(str1);
cd(currFolder);

copyfile(tempPath,copyPath);
% Renaming files
for iFile=1:1:size(copyFilePath,1)
    movefile(outputFilePath(iFile,:),copyFilePath(iFile,:))
end
% Delete auxiliary latex files
delete([copyPath,'\','template*.*']);
    function [latexFilePath,latexCommand]=saveMarketSwaption(saveAt)
        latexCommand=['\marketSwaption',identifier];
        if strcmp(saveAt, '')
            latexFilePath='swaptionMarket.tex';
        else
            latexFilePath=[saveAt,'\','swaptionMarket.tex'];
            mkDir([tempPath,'\',saveAt]);
        end
        data=[maturitySwap,marketSwapPrice];
        file = fopen([tempPath,'\',latexFilePath],'a'); 
        fprintf(file,...
                '\\newcommand{%s}{\n',latexCommand);
        fprintf(file,...
                '\\renewcommand{\\arraystretch}{1}\n');
        fprintf(file,...
                '\\begin{tabular}{|c|*{%d}{c}|}\n',size(data,2)-1);
        fprintf(file,...
                '\\hline\n');
        fprintf(file,...
                '\\diagbox{Maturity}{Tenor} & ');
        for i=1:1:length(tenorSwap)
            if i < length(tenorSwap)
                fprintf(file,'%d & ',tenorSwap(i));
            else
                fprintf(file,'%d \\\\\n ',tenorSwap(i));
            end
        end
        fprintf(file,...
                '\\hline\n');
        fprintf(file,...
                mat2TableBody(data));
        fprintf(file,...
                '\\\\\\hline\n');
        fprintf(file,...
                '\\end{tabular}\n');
        fprintf(file,...
                '}\n');
        fclose(file);
    end
    function [latexFilePath,latexCommand]=saveStrikeSwaption(saveAt)
        latexCommand=['\strikeSwaption',identifier];
        if strcmp(saveAt, '')
            latexFilePath='swaptionStrike.tex';
        else
            latexFilePath=[saveAt,'\','swaptionStrike.tex'];
            mkDir([tempPath,'\',saveAt]);
        end
        data=[maturitySwap,100*strikeSwap];
        file = fopen([tempPath,'\',latexFilePath],'a'); 
        fprintf(file,...
                '\\newcommand{%s}{\n',latexCommand);
        fprintf(file,...
                '\\renewcommand{\\arraystretch}{1}\n');
        fprintf(file,...
                '\\begin{tabular}{|c|*{%d}{c}|}\n',size(data,2)-1);
        fprintf(file,...
                '\\hline\n');
        fprintf(file,...
                '\\diagbox{Maturity}{Tenor} & ');
        for i=1:1:length(tenorSwap)
            if i < length(tenorSwap)
                fprintf(file,'%d & ',tenorSwap(i));
            else
                fprintf(file,'%d \\\\\n ',tenorSwap(i));
            end
        end
        fprintf(file,...
                '\\hline\n');
        fprintf(file,...
                mat2TableBodyPercent(data));
        fprintf(file,...
                '\\\\\\hline\n');
        fprintf(file,...
                '\\end{tabular}\n');
        fprintf(file,...
                '}\n');
        fclose(file);
    end    
    function [latexFilePath,latexCommand]=saveCalibrationTimes(saveAt)
        latexCommand=['\ctimeTests',identifier];
        if strcmp(saveAt, '')
            latexFilePath='ctimeTests.tex';
        else
            latexFilePath=[saveAt,'\','ctimeTests.tex'];
            mkDir([tempPath,'\',saveAt]);
        end
        file = fopen([tempPath,'\',latexFilePath],'a'); 
        % Whole table
        fprintf(file,...
                '\\newcommand{%s}{\n',latexCommand);
        fprintf(file,'\\renewcommand{\\arraystretch}{1}\n');
        fprintf(file,'\\begin{tabular}{c*{%d}{c}}\n',3);
        header();
        fprintf(file,'\\hline\n');
        body();
        fprintf(file,'\\end{tabular}\n');
        fprintf(file,'}\n');
        fprintf(file,'\\newcommand{%s}{\n',[latexCommand,'Body']);
        body();
        fprintf(file,'}\n');
        fprintf(file,'\\newcommand{%s}{\n',[latexCommand,'Header']);
        header();
        fprintf(file,'}\n');
        fprintf(file,'\\newcommand{%s}{\n',[latexCommand,'Data']);
        tabData();
        fprintf(file,'}\n');
        fprintf(file,'\\newcommand{%s}{\n',[latexCommand,'Description']);
        tabDescription();
        fprintf(file,'}\n');
        fclose(file);
        function body()
            for i=1:1:length(params)
                fprintf(file,...
                    '%s &',params{i});
                fprintf(file,...
                    '$%3.3f$ &',ctimes(i));
                fprintf(file,...
                    '$%g\\,\\%%$',100*MREs(i));
                if i < length(params)
                    fprintf(file,'\\\\\n');
                else
                    fprintf(file,'\n');
                end
            end
        end
        function tabData()
            for i=1:1:length(params)
                fprintf(file,...
                    '$%3.3f$ &',ctimes(i));
                fprintf(file,...
                    '$%g\\,\\%%$',100*MREs(i));
                if i < length(params)
                    fprintf(file,'\\\\\n');
                else
                    fprintf(file,'\n');
                end
            end
        end
        function tabDescription()
            for i=1:1:length(params)
                fprintf(file,...
                    '%s',params{i});
                if i < length(params)
                    fprintf(file,'\\\\\n');
                else
                    fprintf(file,'\n');
                end
            end
        end
        function header()
            fprintf(file,...
                'Inital Parameter & Times (in s) & MRE (in \\%%) \\\\\n');
        end
    end    
    function [latexFilePath,latexCommand]=saveErrorSwaption(saveAt)
        latexCommand=['\errorSwaption',identifier];
        if strcmp(saveAt, '')
            latexFilePath='swaption.tex';
        else
            latexFilePath=[saveAt,'\','swaption.tex'];
            mkDir([tempPath,'\',saveAt]);
        end
        data=[maturitySwap,100*errorSwap];
        file = fopen([tempPath,'\',latexFilePath],'a'); 
        fprintf(file,...
                '\\newcommand{%s}{\n',latexCommand);
        fprintf(file,...
                '\\renewcommand{\\arraystretch}{1}\n');
        fprintf(file,...
                '\\begin{tabular}{|c|*{%d}{c}|}\n',size(data,2)-1);
        fprintf(file,...
                '\\hline\n');
        fprintf(file,...
                '\\diagbox{Maturity}{Tenor} & ');
        for i=1:1:length(tenorSwap)
            if i < length(tenorSwap)
                fprintf(file,'%d & ',tenorSwap(i));
            else
                fprintf(file,'%d \\\\\n ',tenorSwap(i));
            end
        end
        fprintf(file,...
                '\\hline\n');
        fprintf(file,...
                mat2TableBodyPercent(data));
        fprintf(file,...
                '\\\\\\hline\n');
        fprintf(file,...
                '\\end{tabular}\n');
        fprintf(file,...
                '}\n');
        fclose(file);
    end    
    function [latexFilePath,latexCommand]=saveEulerParam(saveAt)
        latexCommand=['\eulerParam',identifier];
        if strcmp(saveAt, '')
            latexFilePath='euler.tex';
        else
            latexFilePath=[saveAt,'\','euler.tex'];
            mkDir([tempPath,'\',saveAt]);
        end
        file = fopen([tempPath,'\',latexFilePath],'a'); 
        fprintf(file,...
                '\\newcommand{\\simulations%s}{%d}\n',identifier,M);
        tempDt=strsplit(strrep(rats(dt),' ',''),'/');
        nom=tempDt{1};
        denom=tempDt{2};
        fprintf(file,...
                '\\newcommand{\\timeMesh%s}{\\frac{%s}{%s}}\n',identifier,nom,denom);
        fprintf(file,...
                '\\newcommand{%s}{\n',latexCommand);
        fprintf(file,...
                'We used $M=\\simulations%s$ simulations and a mesh of $\\Delta=\\timeMesh%s$\n',...
                identifier,identifier);
        fprintf(file,...
                '}\n');
        fclose(file);
    end
    function [latexFilePath,latexCommand]=saveCompTimes(saveAt)
        latexCommand=['\ctime',identifier];
        if strcmp(saveAt, '')
            latexFilePath='ctime.tex';
        else
            latexFilePath=[saveAt,'\','ctime.tex'];
            mkDir([tempPath,'\',saveAt]);
        end
        data=[ctimeGa,ctimeFmin,ctimeSim];
        file = fopen([tempPath,'\',latexFilePath],'a'); 
        fprintf(file,...
                '\\SaveVerb{ga}=ga=\n');
        fprintf(file,...
                '\\SaveVerb{fmin}=fmin=\n');
        fprintf(file,...
                '\\newcommand{%s}{\n',latexCommand);
        fprintf(file,...
                '\\renewcommand{\\arraystretch}{1}\n');
        fprintf(file,...
                '\\begin{tabular}{@{}*{%d}{c}@{}}\n',size(data,2));
        fprintf(file,...
                'Time \\UseVerb{ga} (in s)& Time \\UseVerb{fmin} (in s) & Time for simulations (in s)\\\\\n');
        fprintf(file,...
                mat2TableBody(data));
        fprintf(file,...
                '\\end{tabular}\n');
        fprintf(file,...
                '}\n');
        fclose(file);
    end
    function [latexFilePath,latexCommand]=saveDFMeanErr(saveAt)
        latexCommand=['\dfMeanErr',identifier];
        if strcmp(saveAt, '')
            latexFilePath='dfMeanErr.tex';
        else
            latexFilePath=[saveAt,'\','dfMeanErr.tex'];
            mkDir([tempPath,'\',saveAt]);
        end
        data=[marketTimes,dfMeanErr];
        file = fopen([tempPath,'\',latexFilePath],'a'); 
        fprintf(file,'\\newcommand{%s}{\n',latexCommand);
        fprintf(file,'\\renewcommand{\\arraystretch}{1}\n');
        fprintf(file,'\\begin{tabular}{@{}*{%d}{c}@{}}\n',size(data,2));
        header();
        fprintf(file,'\\hline\n');
        body();
        fprintf(file,'\\end{tabular}\n');
        fprintf(file,'}\n');
        fprintf(file,'\\newcommand{%s}{\n',[latexCommand,'Body']);
        body();
        fprintf(file,'}\n');
        fprintf(file,'\\newcommand{%s}{\n',[latexCommand,'Header']);
        header();
        fprintf(file,'}\n');
        fprintf(file,'\\newcommand{%s}{\n',[latexCommand,'Data']);
        tabData();
        fprintf(file,'}\n');
        fclose(file);
        function body()
            fprintf(file,mat2TableBody(data));
        end
        function tabData()
            fprintf(file,mat2TableBody(dfMeanErr));
        end
        function header()
            fprintf(file,...
            'Maturity (in years) & Mean Error of Discount Factor\\\\\n');
        end
    end
    function [latexFilePath,latexCommand]=saveMarketData(saveAt)
        latexCommand=['\marketData',identifier];
        if strcmp(saveAt, '')
            latexFilePath='marketData.tex';
        else
            latexFilePath=[saveAt,'\','marketData.tex'];
            mkDir([tempPath,'\',saveAt]);
        end
        data=[marketTimes,100*marketZeroRates,marketDF];
        file = fopen([tempPath,'\',latexFilePath],'a');
        fprintf(file,...
                '\\newcommand{%s}{\n',latexCommand);
        fprintf(file,...
                '\\renewcommand{\\arraystretch}{1}\n');
        fprintf(file,...
                '\\begin{tabular}{|*{%d}{c}|}\n',size(data,2));
        fprintf(file,'\\hline\n');
        fprintf(file,...
                'Maturity (in years) & Zero rate (in \\%%) & Zero-coupon price\\\\\n');
        fprintf(file,'\\hline\n');
        fprintf(file,...
                mat2TableBodyPrecise(data));
        fprintf(file,'\\\\\\hline\n');
        fprintf(file,...
                '\\end{tabular}\n');
        fprintf(file,...
                '}\n');
        fclose(file);
    end
    function [latexFilePath,latexCommand]=saveCIRParameters(saveAt)
        % % parameters for $x_t$
        % phi1x = params(1);
        % phi2x = params(2);
        % phi3x = params(3);
        % xt0   = params(7);
        % 
        % % parameters for $y_t$
        % phi1y = params(4);
        % phi2y = params(5);
        % phi3y = params(6);
        % yt0   = params(8);
        latexCommand=['\cirParamTable',identifier;'\cirErrorTable',identifier];
        if strcmp(saveAt, '')
            latexFilePath='cirParam.tex';
        else
            latexFilePath=[saveAt,'\','cirParam.tex'];
            mkDir([tempPath,'\',saveAt]);
        end
        file = fopen([tempPath,'\',latexFilePath],'a');
        fprintf(file,...
                '\\newcommand{\\phiOneX%s}{%g}\n',identifier,paramFmin(1));
        fprintf(file,...
                '\\newcommand{\\phiTwoX%s}{%g}\n',identifier,paramFmin(2));
        fprintf(file,...
                '\\newcommand{\\phiThreeX%s}{%g}\n',identifier,paramFmin(3));
        fprintf(file,...
                '\\newcommand{\\xZero%s}{%g}\n',identifier,paramFmin(7));
        fprintf(file,...
                '\\newcommand{\\phiOneY%s}{%g}\n',identifier,paramFmin(4));
        fprintf(file,...
                '\\newcommand{\\phiTwoY%s}{%g}\n',identifier,paramFmin(5));
        fprintf(file,...
                '\\newcommand{\\phiThreeY%s}{%g}\n',identifier,paramFmin(6));
        fprintf(file,...
                '\\newcommand{\\yZero%s}{%g}\n',identifier,paramFmin(8));
        fprintf(file,...
                '\\newcommand{\\errFmin%s}{%e}\n',identifier,errFmin);
        fprintf(file,...
                '\\newcommand{\\MRE%s}{%3.3f\\,\\%%}\n',identifier,100*meanRelL1Err);
        fprintf(file,...
                '\\newcommand{\\MSRE%s}{%3.3f\\,\\%%}\n',identifier,100*meanRelL2Err);
        % Param table
        fprintf(file,...
                '\\newcommand{%s}{\n',latexCommand(1,:));
        fprintf(file,...
                '\\begin{tabular}{@{}*{8}{c}@{}}\n');
        fprintf(file,...
                '$\\phi_1^x$ & $\\phi_2^x$ & $\\phi_3^x$ & $x_0$ & ');
        fprintf(file,...
                '$\\phi_1^y$ & $\\phi_2^y$ & $\\phi_3^y$ & $y_0$\\\\\n'); 
        fprintf(file,...
                '$\\phiOneX%s$ & $\\phiTwoX%s$ & $\\phiThreeX%s$ & $\\xZero%s$ & ',...
                identifier,identifier,identifier,identifier);
        fprintf(file,...
                '$\\phiOneY%s$ & $\\phiTwoY%s$ & $\\phiThreeY%s$ & $\\yZero%s$ \\\\\n',...
                identifier,identifier,identifier,identifier);
        fprintf(file,...
                '\\end{tabular}\n');
        fprintf(file,...
                '}\n');  
        % Error table
        fprintf(file,...
                '\\newcommand{%s}{\n',latexCommand(2,:));
        fprintf(file,...
                '\\begin{tabular}{@{}*{3}{c}@{}}\n');
        fprintf(file,...
                '$f(\\Pi)$ & \\textbf{MRE} & \\textbf{MSRE} \\\\\n ');
        fprintf(file,...
                '$\\errFmin%s$ & $\\MRE%s$ & $\\MSRE%s$\n',...
                identifier,identifier,identifier);
        fprintf(file,...
                '\\end{tabular}\n');
        fprintf(file,...
                '}\n'); 
        
        fprintf(file,...
                '%%\\begin{tabular}{@{}*{9}{c}@{}}\n');
        fprintf(file,...
                '%%$\\phi_1^x$ & $\\phi_2^x$ & $\\phi_3^x$ & $x_0$ & ');
        fprintf(file,...
                '$\\phi_1^y$ & $\\phi_2^y$ & $\\phi_3^y$ & $y_0$ & Error\\\\\n'); 
        fprintf(file,...
                '%%$%g$ & $%g$ & $%g$ & $%g$ &',...
                paramFmin(1:3),paramFmin(4));
        fprintf(file,...
                '$%g$ & $%g$ & $%g$ & $%g$ & $%g$\\\\\n',...
                paramFmin(5:end)); 
        fprintf(file,...
                '%%\\end{tabular}\n'); 
        fclose(file);
    end
    function [latexFilePath,latexCommand]=saveModelParameters(saveAt)
        % % parameters for $x_t$
        % kx = modelParam(1);
        % sigmax = modelParam(2);
        % thetax = modelParam(3);
        % 
        % % parameters for $y_t$
        % ky = modelParam(4);
        % sigmay = modelParam(5);
        % thetay = modelParam(6);;
        latexCommand=['\modelParamTable',identifier];
        if strcmp(saveAt, '')
            latexFilePath='modelParam.tex';
        else
            latexFilePath=[saveAt,'\','modelParam.tex'];
            mkDir([tempPath,'\',saveAt]);
        end
        file = fopen([tempPath,'\',latexFilePath],'a');
        fprintf(file,...
                '\\newcommand{\\kX%s}{%g}\n',identifier,modelParam(1));
        fprintf(file,...
                '\\newcommand{\\sigmaX%s}{%g}\n',identifier,modelParam(2));
        fprintf(file,...
                '\\newcommand{\\thetaX%s}{%g}\n',identifier,modelParam(3));
        fprintf(file,...
                '\\newcommand{\\kY%s}{%g}\n',identifier,modelParam(4));
        fprintf(file,...
                '\\newcommand{\\sigmaY%s}{%g}\n',identifier,modelParam(5));
        fprintf(file,...
                '\\newcommand{\\thetaY%s}{%g}\n',identifier,modelParam(6));
        fprintf(file,...
                '\\newcommand{%s}{\n',latexCommand);
        fprintf(file,...
                '\\begin{tabular}{@{}*{6}{c}@{}}\n');
        fprintf(file,...
                '$k_x$ & $\\sigma_x$ & $\\theta_x$ & ');
        fprintf(file,...
                '$k_y$ & $\\sigma_y$ & $\\theta_y$ \\\\\n'); 
        fprintf(file,...
                '$\\kX%s$ & $\\sigmaX%s$ & $\\thetaX%s$ & ',...
                identifier,identifier,identifier);
        fprintf(file,...
                '$\\kY%s$ & $\\sigmaY%s$ & $\\thetaY%s$ \\\\\n',...
                identifier,identifier,identifier);
        fprintf(file,...
                '\\end{tabular}\n');
        fprintf(file,...
                '}\n');   
        fprintf(file,...
                '%%\\begin{tabular}{@{}*{6}{c}@{}}\n');
        fprintf(file,...
                '%%$k_x$ & $\\sigma_x$ & $\\theta_x$ & ');
        fprintf(file,...
                '$k_y$ & $\\sigma_y$ & $\\theta_y$ \\\\\n');  
        fprintf(file,...
                '%%$%g$ & $%g$ & $%g$ & ',...
                modelParam(1:3));
        fprintf(file,...
                '$%g$ & $%g$ & $%g$ \\\\\n',...
                modelParam(4:6)); 
        fprintf(file,...
                '%%\\end{tabular}\n'); 
        fclose(file);
    end
    function latexFilePath=saveFigures(figures,saveAt,figName)
        if strcmp(figName,'')
            figName='fig';
        end
        if strcmp(saveAt, '')
            latexFilePath='figure.tex';
            latexFolderPath=tempPath;
        else
            latexFilePath=[saveAt,'\','figure.tex'];
            latexFolderPath=[tempPath,'\',saveAt];
            mkDir([tempPath,'\',saveAt]);
        end
        file = fopen([tempPath,'\',latexFilePath],'a');
        for i=1:1:length(figures)
            picName=sprintf('%s_%d',figName,i);
            picPath = [latexFolderPath,'\',picName,'.',picType];
            if strcmp(saveAt, '')
                relPicPath=picName;
            else
                relPicPath=[saveAt,'\',picName];
            end
            saveas(figures(i),picPath,saveParam);
            fprintf(file,...
                '\\begin{landscape}\n');
            fprintf(file,...
                '\\includegraphics[width=.95\\columnwidth]{%s}\n',...
                changeSlash(relPicPath));
            fprintf(file,...
                '\\end{landscape}\n');
        end
        fclose(file);
    end


end
function str=changeSlash(str)
    for i=1:1:length(str)
        if strcmp(str(i),'\')
            str(i)='/';
        end
    end
end
function delFile(file)
    if exist(file)
        delete(file);
    end
end
function delDir(dir)
    if exist(dir)==7
        rmdir(dir,'s');
    end
end
function cleanDir(mdir,except)
    except{end+1}='.';
    except{end+1}='..';
    for d = dir(mdir).'
      if ~any(strcmp(d.name,except))
          if d.isdir
              rmdir([d.folder,'\',d.name],'s');
          else
              delete([d.folder,'\',d.name]);
          end
      end
    end
end
function mkDir(dir)
    if exist(dir)==0
        mkdir(dir);
    end
end
function latexStr=mat2TableBodyPrecise(mat)
    latexStr='';
    for i=1:1:size(mat,1)
        for j=1:1:size(mat,2)
            if j < size(mat,2)
                temp=sprintf('$%17.15g$ & ',mat(i,j));
            else
                temp=sprintf('$%17.15g$ ',mat(i,j));
            end
            latexStr=[latexStr,temp];
        end
        if i < size(mat,1)
            temp='\\\\\n';
        else
            temp='';
        end
        latexStr=[latexStr,temp];
    end
end
function latexStr=mat2TableBody(mat)
    latexStr='';
    for i=1:1:size(mat,1)
        for j=1:1:size(mat,2)
            if j < size(mat,2)
                temp=sprintf('$%g$ & ',mat(i,j));
            else
                temp=sprintf('$%g$ ',mat(i,j));
            end
            latexStr=[latexStr,temp];
        end
        if i < size(mat,1)
            temp='\\\\\n';
        else
            temp='\n';
        end
        latexStr=[latexStr,temp];
    end
end
function latexStr=mat2TableBodyPercent(mat)
    latexStr='';
    for i=1:1:size(mat,1)
        for j=1:1:size(mat,2)
            if j == 1
                temp=sprintf('$%d$ & ',mat(i,j));               
            else
                if j < size(mat,2)
                    temp=sprintf('$%g\\\\,\\\\%%%% $ & ',mat(i,j));
                else
                    temp=sprintf('$%g\\\\,\\\\%%%% $ ',mat(i,j));
                end
            end
            latexStr=[latexStr,temp];
        end
        if i < size(mat,1)
            temp='\\\\\n';
        else
            temp='\n';
        end
        latexStr=[latexStr,temp];
    end
end