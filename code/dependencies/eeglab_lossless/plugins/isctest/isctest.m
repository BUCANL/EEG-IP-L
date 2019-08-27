%  ISCTEST: Testing independent components by intersession/subject consistency
%
%  Version 2.2, Feb 2013
%  Aapo Hyvarinen, University of Helsinki 
%
%  clustering=ISCTEST(spatialPattTens,alphaFP,alphaFD,'components') tests
%    the matrices of independent components (e.g. spatial patterns in fMRI), 
%    previously estimated by ICA, for consistency
%    over the different data sets (subjects/sessions) from which they were
%    estimated. It returns the set of clusters which are considerent 
%    statistically significant. 
%
%  clustering=ISCTEST(spatialPattTens,alphaFP,alphaFD,'mixing') tests
%    the columns of the mixing matrix instead of the independent components.
%
%  See http://www.cs.helsinki.fi/u/ahyvarin/code/isctest/ for more information
%
%
%  INPUT VARIABLES
%
%  spatialPattTens: 3-D tensor which gives the vectors to be tested.
%    Each matrix spatialPattTens(:,:,k) is the matrix of the spatial patterns 
%    for the k-th subject. 
%    In the case of ICA, it is usually the ICA results in the following sense:
%      for temporal ICA (MEG/EEG), spatialPattTens(:,:,k) is the mixing matrix A
%      for spatial ICA (fMRI), spatialPattTens(:,:,k)  is the matrix S transposed
%    Thus, the indices are: channel(E/MEG)/voxel(fMRI), component, subject
%
%  alphaFP,alphaFD: alpha levels in testing, i.e.
%    false positive (FP) and false discovery (FD) rates, respectively.
%    These are the values before any correction,
%    so typical values would be 0.05 for both.
%
%  You can also add further options at the end of the function call. 
%  For example:
%  clustering=ISCTEST(spatialPattTens,alphaFP,alphaFD,'silent','CL')
%  suppresses disgnostics to the terminal, and uses complete linkage clustering.
%  See the code below for all the available options.
%
%
%  OUTPUT VARIABLES
%
%  clustering: the matrix giving the obtained clustering.
%    Each "row" is one cluster. 
%    If there is a non-zero entry, say equal to j, 
%    in the k-th column of the i-th row,
%    it means the i-th cluster contains the j-th component of the k-th subject.
%
%  The following output variables have the same structure as "clustering",
%  and they are optional, "clustering" containing the main result.
%  To obtain them, just add more output arguments to the function call.
%
%  clusterorder: 
%    Matrix giving the order in which the vectors were added to the cluster.
%
%  linkpvalues:
%    Matrix giving the p-values used in connecting each component to a cluster.
%
%  linksimilarities:
%    Matrix giving the similarities connecting each component to a cluster.
%
%  It is also possible to get the following output variables:
%
%  simitensor,maxtensor,pvalues
%    These contain the raw similarities and pvalues used in forming clusters.
%    To save memory and computation, only the maximal similarities are stored.
%    simitensor(i,k,l) contains the maximum similarity between 
%      the i-th component of subject k and all the components of subject l.
%    maxtensor(i,k,l)==j means the maximum was attaind by j-th component.
%    pvalues(i,k,l) contains the (uncorrected) p-values, 
%      indices being the same as in simitensor.
%

function [clustering,clusterorder,linkpvalues,linksimilarities,...
          simitensor,maxtensor,pvalues]...
  =isctest(spatialPattTens,alphaFP,alphaFD,varargin)



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%SET PARAMETERS TO DEFAULT VALUES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%STRATEGY FOR LINKING (see below for options)
strategy='SL';
%USE SIMES PROCEDURE OR NEW DEFINITION OF FDR?
simes=0;
%CORRECT ERROR RATES FOR MULTIPLE TESTING, OR ASSUME THEY ARE ALREADY CORRECTED (if you want to compute them yourself for some reason)
corrected=0;
%Do we show diagnostics on screen? (0/1/2)
verbose=1;
%The user has to tell what to test (components/mixing) to avoid misunderstanding
testingComponents=NaN;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%READ OPTIONS FROM FUNCTION CALL AND CHANGE DEFAULT VALUES ABOVE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Some of these repeat default settings for future compatibility

options=varargin;
for optionind=1:length(options)
  switch options{optionind}
   %ARE INPUTS INDEPENDENT COMPONENTS OR COLUMNS OF MIXING MATRIX   
   %i.e. basic choice of what to test, and the ensuing testing approach (analytic or empirical)
   case 'mixing', testingComponents=0; empirical=0; 
   case 'components', testingComponents=1; empirical=1;
   %You may also want to set the testing approach independently here:
   case 'analytic', empirical=0; %analytic approach in 2011 paper
   case 'empirical', empirical=1;  %empirical approach in 2013 paper
   %Screen output options:
   case 'silent', verbose=0; %print no output on screen
   case 'verbose', verbose=1; %print moderate output on screen
   case 'extraverbose', verbose=2; %print some extra diagnostics
   %Linkage strategies
   case 'CL', strategy='CL'; %complete-linkage
   case 'ML', strategy='ML'; %median-linkage (original)
   case 'SL', strategy='SL';  %single-linkage
   %Statistical options
   case 'simes', simes=1;     %use Simes procedure for FDR computation (not recommended)
   case 'customfdr', simes=0;  %use our new method for FDR computation
   case 'corrected', corrected=1; %if you want to compute corrected alphas yourself, choose this

  otherwise error(['Unknown option: "',options{optionind},'"'])
  end
end
if isnan(testingComponents), 
   error('You must specify if we are testing components or columns of mixing matrix, input either option ''components'' or ''mixing''.')
end

%READ BASIC DIMENSIONS
datadim  = size(spatialPattTens,1);
pcadim   = size(spatialPattTens,2);
subjects = size(spatialPattTens,3);
%Check if we have complex-valued data
complexvalued=~isreal(spatialPattTens);

%INITIAL OUTPUT TO USER
if verbose
  fprintf('\n*** ISCTest: ICA testing algorithm ***\n')
  fprintf('Input parameters:\n')
  fprintf('  Number of subjects: %u \n',subjects)
  fprintf('  Number of vectors/components per subject: %u \n',pcadim)
  fprintf('  Data vector dimension: %u \n',datadim)
  fprintf('  False positive rate: %g \n',alphaFP)
  fprintf('  False discovery rate: %g \n',alphaFD)
  if complexvalued, 
    fprintf('  Data is complex-valued,'); 
    fprintf(' distributions adjusted accordingly\n'); 
  end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% COMPUTE SIMILARITIES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Compute maximal parts of similarity tensor, and store information on which
%connections were maximal, as well as 2nd order moments of the tensor
[simitensor,maxtensor,simimom2]=...
computeSimilarities(spatialPattTens,testingComponents,verbose);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DO CLUSTERING in deflation mode
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if verbose, fprintf('\n*** Launching clustering computations ***\n'), end

%In analytical method, needs two iterations
%but in empirical method, only one is needed
if empirical
  iterations=1;
else
  iterations=2;
end

%Loop for the two iterations in analytical method
for iteration=1:iterations

if verbose  
  if empirical,  
    fprintf('Starting iteration, forming cluster ')
  else
    fprintf('Starting iteration %i, forming cluster ',iteration); 
  end
end


%Initialize the tensor which gives the set of pvalues which have not been deflated away
deflationtensor=zeros(pcadim,subjects,subjects);
%Initialize output variables
clustering=[];
clusterorder=[];
linkpvalues=[];
linksimilarities=[];


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%MAIN LOOP FOR CLUSTERING (EACH TIME FINDING A NEW CLUSTER) 
%STARTS HERE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Boolean variable which tell when to stop
nomoreclusters=0; 
%Initialize iteration counter
clusterindex=1;

while ~nomoreclusters

if verbose,  fprintf('.',clusterindex), end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%COMPUTE EFFECTIVE DIMENSIONS 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if empirical 
    %General case of empirical thresholds:
    %Estimate effective dimension 
    %based on the empirical distribution of similarities
    %Using method of moments estimator for beta (which gives effdim)
    if ~complexvalued
      effdimest=1/simimom2;
    else 
      %This case (testing complex-valued independent components) has not been 
      %properly tested because because it is unlikely to occur in practice
      effdimest=1/simimom2-.5; 
    end
    %This global estimate is taken for all subject pairs, in empirical method
    effdim=effdimest*ones(subjects,subjects); 

else 
  %case of analytically computed thresholds
  if iteration==1 %only computed in first iteration, fixed in second iteration
    if clusterindex==1 %If first cluster, use full dimension
      effdim=pcadim*ones(subjects,subjects); 
    else %if not first cluster, compute new dimension parameters 
         %from the results of current clustering 
      %first compute effdim, starting from pcadim and reducing it
      neweffdim=pcadim*ones(subjects,subjects);
      for c=1:size(clustering,1)
      clustersize=sum(clustering(c,:)>0);
      for s1=1:subjects
        for s2=(s1+1):subjects
          %for each pair of component in the same cluster,
          %reduce new effdim of that similarity by 1
          %for numerical stability retain minimum of 2
          if clustering(c,s1)>0 & clustering(c,s2)>0
            neweffdim(s1,s2)=max(2,neweffdim(s1,s2)-1); 
            neweffdim(s2,s1)=max(2,neweffdim(s2,s1)-1); 
          end
        end
      end
      end
      %Update effdim
      effdim=neweffdim;
    end
  end
end  


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% COMPUTE P-VALUES USING BETA DISTRIBUTION
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Compute p-values based on cdf of beta distribution
%We raise the p-values to pcadim-th power because 
%the simitensor contains the maximal similarities for each component
pvalues=ones(size(simitensor));
for subj1=1:subjects
  for subj2=1:subjects
    if ~complexvalued

      %Basic formula for real-valued data
      pvalues(:,subj1,subj2)=1-betainc(simitensor(:,subj1,subj2).^2,0.5,...
                              (effdim(subj1,subj2)-1)/2).^(pcadim);  
    else 

      %Formula for complex-valued data (usually mixing matrix)
      %where the effective dimensions must be multiplied by two
      %and the first parameters is equal to one
      pvalues(:,subj1,subj2)=1-betainc(simitensor(:,subj1,subj2).^2,1,...
                              (2*effdim(subj1,subj2)-1)/2).^(pcadim);

    end
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%DEFLATION: REMOVE THOSE CONNECTIONS WHICH SHOULD NOT BE USED
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%First create matrix which contains all the p-values, 
%even those deflated away (needed for FDR computation by Simes)
pvalues_nodefl=pvalues;
%And now do deflation: Set to one those pvalues which have been deflated away
pvalues=max(pvalues_nodefl,deflationtensor);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% COMPUTE THRESHOLDS FOR P-VALUES CORRECTED FOR MULTIPLE TESTING
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if corrected %if the user input corrected values, just use them

  alphacorr_FP=alphaFP;
  alphacorr_FD=alphaFD;

else %otherwise do correction here

  %Compute Bonferroni-corrected FPR threshold (forming a new cluster)
  alphacorr_FP= alphaFP / (subjects*(subjects-1)*pcadim/2); 

  %Compute corrected FDR threshold 
  if simes %Simes procedure (well-known FDR method)
    %Note: here we use all p-values even those deflated away
    %    (ignoring only duplicates due to symmetry by using uppertriangindices)
    pvalues_FDR = sort(pvalues_nodefl(uppertriangindices(pcadim,subjects)));
    alphacorr_FD=pvalues_FDR(max(find(pvalues_FDR <=...
                 (1:size(pvalues_FDR,2))'/size(pvalues_FDR,2)*alphaFD)));
    if isempty(alphacorr_FD), alphacorr_FD=0; end
  else %Simple alternative to simes procedure, in 2013 paper
    alphacorr_FD=alphaFD/(subjects-2);
  end

end

%Print some simple diagnostics on screen, if extraverbose
if verbose==2
if ~empirical
fprintf('  Average estimated effective dimension: %6.2f \n',mean(mean(effdim)))
fprintf('  Corrected alpha value for FDR: %e \n',alphacorr_FD);
fprintf('  Corrected alpha value for FPR: %e \n',alphacorr_FP);
end
FDpvalues=sum(sum(sum(pvalues<alphacorr_FD)));
FPpvalues=sum(sum(sum(pvalues<alphacorr_FP)));
fprintf('  Number of similarities left above FDR threshold: %d (%2.6f%%) \n',FDpvalues,FDpvalues/subjects/(subjects-1)/pcadim^2*2*100);
fprintf('  Number of similarities left above FPR threshold: %d (%2.6f%%) \n',FPpvalues,FPpvalues/subjects/(subjects-1)/pcadim^2*2*100);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% MAIN CLUSTERING PART (for creating one cluster)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%FIND INITIAL PAIR OF COMPONENTS TO FORM A CLUSTER
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Find maximum single correlation to start clustering with
[pval minind]=min(pvalues(:));  
  
%Abort if max similarity does not reach threshold given by FPR
%(Or if, exceptionally, pval is equal to one which means zero similarity)
if pval>alphacorr_FP | pval==1  
     nomoreclusters=1;
else %we have cluster, continue adding more components to it
    %First find subject and component number of the minimizing pvalue
    [compind1,subjind1,subjind2]=ind2sub([pcadim,subjects,subjects],minind);
    compind2=maxtensor(minind);
    %add these initial two to lists of components in this cluster.
    %a) create list of subjects in cluster
    clustersubjs=[subjind1,subjind2];
    %b) create list of components in cluster
    clustercomps=[compind1,compind2];
    %c) create list of linking pvalues
    clusterpvalues=[pval,pval];
    %d) create list of linking similarites
    clustersimis=[1,1]*simitensor(compind1,subjind1,subjind2);

    %ADD NEW COMPONENTS TO CURRENT CLUSTER
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Loop to find all components sufficiently connected to those already found
    if subjects>2
      nomorecomponents=0; %boolean which tells if all components have been found
    else
      nomorecomponents=1; %if there are just two subjects in the data,
                                            %no need to even start this adding of new components
    end
    while ~nomorecomponents

      %Create matrix with similarities of components in remaining subjects
      %to those subjects in present cluster
         %First, get indices of subjects not in cluster 
         remainsubjs=ones(1,subjects);
         remainsubjs(clustersubjs)=zeros(size(clustersubjs));
         remainsubjinds=find(remainsubjs);
      pvalues_selected=zeros(size(clustersubjs,2),sum(remainsubjs));
      maxtensor_selected=zeros(size(clustersubjs,2),sum(remainsubjs));
      %for each component in cluster, create row with similarities
      %to all the candidate components (each column is one subject) which could be added
      for i=1:size(clustersubjs,2)
         pvalues_selected(i,:)=...
            pvalues(clustercomps(i),clustersubjs(i),remainsubjinds);     
         maxtensor_selected(i,:)=...
            maxtensor(clustercomps(i),clustersubjs(i),remainsubjinds);     
      end

      %USE DIFFERENT LINKAGE STRATEGIES TO FIND NEW CANDIDATE
      %Get aggregate pvalues from the cluster to candidate components
      switch strategy
      case 'SL' %single-linkage
         [outpvals outmininds]=min(pvalues_selected,[],1);
      case 'CL' %complete-linkage
         %This is a bit tricky because we have to first determine
         %if the links to the same subject are to the same component
         samesimilarity=all(maxtensor_selected==...
              ones(size(maxtensor_selected,1),1)*maxtensor_selected(1,:));
         %Set p-value to ridiculously large if the links not the same subject
         pvalues_selected_qualified=pvalues_selected+...
                     100*(1-ones(size(pvalues_selected,1),1)*samesimilarity);
         %And finally find the max p-values, i.e. weakest links from the cluster
         [outpvals outmininds]=max(pvalues_selected_qualified,[],1);
      case 'ML' %median-linkage
         %First make check like in CL
         samesimilarity=all(maxtensor_selected==...
              ones(size(maxtensor_selected,1),1)*mode(maxtensor_selected));
         pvalues_selected_qualified=pvalues_selected+...
                     100*(1-ones(size(pvalues_selected,1),1)*samesimilarity);
         %The following is like CL, but use median instead of max
         %However, matlab does not give the median indices, so they have to
         %be computed in a special way:
         %Sort each column
         [sortvals,sortinds]=sort(pvalues_selected_qualified,1);
         %Compute indes of median. (If you want to be conservative,
         %add 1 to the size here.
         medianrow=floor((size(pvalues_selected_qualified,1)+1)/2);
         %And then find the median elements
         outpvals=sortvals(medianrow,:);
         outmininds=sortinds(medianrow,:);
      end

      %For any strategy, finally find minimizing pvalue, i.e. best component to add
      %among the significant/allowed connections
      [pval minind]=min(outpvals);

      %See if similarity fails to pass the FDR threshold
      if pval>alphacorr_FD
        %If so, abort since cannot find any sufficiently connected components
        nomorecomponents=1;
      else %If sufficiently similar, add to cluster
        %Find subject and component number of the minimizing pvalue
        %First, subject/component inside cluster 
        %from which the minimizing link goes out
        oldsubj=clustersubjs(outmininds(minind)); 
        oldcomp=clustercomps(outmininds(minind));
        %Second, subject/component outside cluster which is to be added
        %(convert subject index according to ordering in remainsubjinds)
        newsubj=remainsubjinds(minind);
        %(fetch component number from maxtensor)
        newcomp=maxtensor(oldcomp,oldsubj,newsubj);

        %Then add to current cluster
        clustersubjs=[clustersubjs,newsubj];
        clustercomps=[clustercomps,newcomp];
        %Store also linking p-value and similarities
        clusterpvalues=[clusterpvalues,pval];
        clustersimis=[clustersimis,simitensor(oldcomp,oldsubj,newsubj)];

        %if cluster size maximum, abort
        if size(clustersubjs,2)==subjects, nomorecomponents=1; end
      end
    end %of while ~nomorecomponents, i.e.loop for adding components to cluster
  end %of if initial similarity was large enough, i.e. do we start a new cluster

  %(At this point, a new cluster has been processed)

  %If the cluster was not empty, store cluster in matrix and continue
  if ~nomoreclusters
       clustering(clusterindex,:)=zeros(1,subjects);
       clusterorder(clusterindex,:)=zeros(1,subjects);
       linkpvalues(clusterindex,:)=zeros(1,subjects);
       linksimilarities(clusterindex,:)=zeros(1,subjects);

       clustering(clusterindex,clustersubjs)=clustercomps;
       clusterorder(clusterindex,clustersubjs)=[1:size(clustersubjs,2)];       
       linkpvalues(clusterindex,clustersubjs)=clusterpvalues;
       linksimilarities(clusterindex,clustersubjs)=clustersimis;

       %Store also information on which vectors should be deflated, i.e. ignored
       for i=1:size(clustersubjs,2)
         %Easy to do deflation in one direction
         deflationtensor(clustercomps(i),clustersubjs(i),:)=ones(subjects,1);
         %But in the other direction more difficult
         tmpmatrix=maxtensor(:,:,clustersubjs(i));
         incomingindex=find(tmpmatrix==clustercomps(i));
         [comp,subj]=ind2sub([pcadim,subjects],incomingindex);
         for j=1:size(comp)
           deflationtensor(comp(j),subj(j),clustersubjs(i))=1;
         end
       end

       %increment cluster number (iteration counter)
       clusterindex=clusterindex+1;
  end

end %of loop through clusters

%(At this point, all clusters have been found in the current iteration)

if verbose 
  fprintf('Done.\n')
  if iteration==1  & iterations==2  %If we have two iterations, give intermediate results
    fprintf('Number of clusters found in initial iteration: %d \n',...
               size(clustering,1));
    fprintf(['Number of vectors clustered in initial iteration:',...
              ' %d (%2.2f%% of all vectors)\n'],sum(sum(clustering>0)),...
                  sum(sum(clustering>0))/subjects/pcadim*100);
  end
end

%END OF LOOP FOR ITERATING CLUSTERING TWO TIMES when using analytical method:
end

%(At this point, iterations have been finished and final clustering found)
%The rest is just outputting stuff on the terminal:

if verbose
  fprintf('*** Clustering computation finished ***\n\n');
  fprintf('Number of clusters found: %d \n',size(clustering,1));
  compsclustered=sum(sum(clustering>0));
  fprintf('Number of vectors clustered: %d (%2.2f%% of all vectors)\n',...
             compsclustered,compsclustered/subjects/pcadim*100);
  fprintf('Average number of vectors per cluster: %3.2f\n',...
             compsclustered/size(clustering,1));
  fprintf('Internal parameters: \n');
  fprintf('  Average estimated effective dimension: %6.2f \n',...
             mean(mean(effdim)))
  fprintf('  Corrected alpha value for FDR: %e \n',alphacorr_FD);
  fprintf('  Smallest similarity considered significant by FDR: %0.4f \n',...
             min(linksimilarities(find(linksimilarities))));
  fprintf('  Corrected alpha value for FPR: %e \n',alphacorr_FP);
  fprintf('  Smallest similarity considered significant by FPR: %0.4f \n',...
             min(max(linksimilarities')));
  fprintf('Exiting testing algorithm succesfully.\n');
end
