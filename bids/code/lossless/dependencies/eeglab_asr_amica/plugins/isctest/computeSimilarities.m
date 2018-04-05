%Subroutine of ISCTEST, version 2.02
%Computes the similarity tensor and outputs its maximal elements
%as well as information on second-order moments of the tensor
%
%Inputs: the spatial patterns in spatialPattTens,
%        boolean variables testingComponents, verbose
%        All directly from input to isctest.m
%Outputs: The maximal similarities (for each component) in simitensor
%         Information on which components reached the maximum in maxtensor
%         Second-order moments in simimom2, 
%           used in fitting the empirical distributions.
 
function [simitensor,maxtensor,simimom2]=...
     computeSimilarities(spatialPattTens,testingComponents,verbose)

%READ BASIC DIMENSIONS
datadim  = size(spatialPattTens,1);
pcadim   = size(spatialPattTens,2);
subjects = size(spatialPattTens,3);

%Check for any problems in the data
if sum(sum(sum(abs(spatialPattTens),1)==0))>0, 
        fprintf('\nWARNING: There seem to be zero vectors in the input!\n')
end
if sum(sum(sum(isnan(spatialPattTens))))>0, 
   fprintf('\nWARNING: There seem to be NaN vectors in the input, ISCTEST is likely to crash!\n')
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% REMOVE MEANS IF TESTING INDEPENDENT COMPONENTS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

if testingComponents
  for k=1:subjects
    for i=1:pcadim
      spatialPattTens(:,i,k)=spatialPattTens(:,i,k)-...
                  mean(spatialPattTens(:,i,k));
    end
  end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%COMPUTE STABILIZED INVERSE OF COVARIANCE MATRIX IF TESTING MIXING MATRIX
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%This implementation uses SVD which handles very large data dimensions easily.
%First, put all the data together in one matrix by concatenation

if ~testingComponents %Only used in testing mixing matrix

  if verbose
    fprintf('\nComputing stabilized inverse of covariance matrix:\n')
    fprintf('  Concatenating data\n')
  end
  wholedata=zeros(datadim,subjects*pcadim);
  for k=1:subjects
      wholedata(:,((k-1)*pcadim+1):(k*pcadim))=spatialPattTens(:,:,k);
  end
  %Compute singular value decomposition of the concatened data
  if verbose 
    fprintf('  Calling matlab SVD function on matrix of size %u x %u \n',...
               size(wholedata,1),size(wholedata,2))
  end
  [Uorig,sing,Vorig]=svd(wholedata,'econ');
  %Find the pcadim largest singular values
  singd = diag(sing); 
  [dummy,order] = sort(singd,'descend');
  seldim=order(1:pcadim);
  %Order singular values
  singd = singd(seldim)';
  %Check if matrix very badly conditioned
  %and increase small singular values if so
  maxcondition=10; %maximum condition number allowed, you can change this!
  conditionnumber=singd(1)/singd(pcadim);
  if conditionnumber>maxcondition
    changedsings=sum(singd<singd(1)/maxcondition);
    singd=max(singd,singd(1)/maxcondition);
    if verbose
      if conditionnumber<2*maxcondition
       fprintf('  Global covariance matrix moderately badly conditioned:\n') 
      else
       fprintf('  WARNING: Global covariance matrix quite badly conditioned!\n')
      end
      fprintf('    Original condition number %g\n',conditionnumber) 
      fprintf('    Increased  %u smallest singular values\n',changedsings)
    end
  end
  %Compute the matrices U and D    
  U = Uorig(:,seldim);
  D=diag(1./singd.^2)*datadim*pcadim;
  if verbose
    fprintf('  Stabilized inverse computed:')
    fprintf(' condition number is %g\n',singd(1)/singd(pcadim))
  end
  %Now, stabilized inverse of covariance is given by U*D*U'
  %Instead of computing it here, 
  %we plug these matrices directly to formulae below to optimize computation
  %because the matrix U*D*U' can be very large but has very low rank.
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%COMPUTE SIMILARITIES AND STORE MAX INTER-SUBJECT SIMILARITIES
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if verbose
  fprintf('Computing similarities and storing maximal ones: ')
end
%Create first tensors in which similarities stored
%For each component, we store only the maximum similarities to other subjects
simitensor=zeros(pcadim,subjects,subjects); %values of max similarities
maxtensor=zeros(pcadim,subjects,subjects); %which components reached the max
%for empirical test, compute 2nd moments of similarity distribution
simimom2=0;
for subj1=1:subjects
  if verbose, fprintf('.'); end
  M1=spatialPattTens(:,:,subj1);
  if testingComponents %if testing components, normalize simply
     M1=M1./sqrt(ones(datadim,1)*(diag(M1'*M1))'+1e-100);
  else %if testing mixing matrix, normalize by weighted norm
    M1=M1./sqrt(ones(datadim,1)*(diag(M1'*U*D*U'*M1))'+1e-100);
  end
  for subj2=1:subjects
      M2=spatialPattTens(:,:,subj2);
      if testingComponents %normalize as above
        M2=M2./sqrt(ones(datadim,1)*(diag(M2'*M2))'+1e-100);
      else
        M2=M2./sqrt(ones(datadim,1)*(diag(M2'*U*D*U'*M2))'+1e-100);
      end
      if testingComponents %if testing components, simple correlations
        similarities=abs(M1'*M2);
      else %if testing mixing matrix, weighted correlations
        similarities=abs(M1'*U*D*U'*M2);
      end
      if subj1~=subj2
        [maxsimis,maxindices]=max(similarities');
        simitensor(:,subj1,subj2)=maxsimis';
        maxtensor(:,subj1,subj2)=maxindices';
        simimom2=simimom2+sum(sum((similarities).^2));
      end

  end
end 

%Compute moments used only in determining empirical thresholds
simimom2=simimom2/(subjects*(subjects-1)*pcadim^2);

%Due to numerical inaccuracies, similarities can be slightly larger than 1.
%This needs to be corrected to avoid error in betainc function.
simitensor=min(simitensor,1);

if verbose, fprintf('Done\n'); end
