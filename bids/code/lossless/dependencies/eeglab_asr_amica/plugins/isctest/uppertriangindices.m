%Subroutine of ISCTEST
%This function gives the indices which correspond to upper 
%triangular parts of the similarity/p-value matrices to remove duplicates
%Only similarities/pvalues with these indices will be used in 
%Simes' procedure 

function indices=uppertriangindices(pcadim,subjects)

mask=zeros(pcadim,subjects,subjects);
for subj1=1:subjects
  for subj2=1:subj1-1;
    mask(:,subj1,subj2)=ones(pcadim,1);
   end
end
indices=find(mask(:)) ;

