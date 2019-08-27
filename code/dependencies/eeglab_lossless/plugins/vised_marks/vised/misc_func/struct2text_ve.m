function struct2text_ve(instruct,savename)

% if nargin==1;
    %fid = fopen([savename, '.txt'], 'wt+');
    
fid = fopen(savename, 'wt+');
% elseif nargin>1;
%     fid=varargin{2};
%     parent=varargin{1};
% end

%nl=0;
fn=fieldnames(instruct);

for i = 1:length(fn)
    
    if iscell(instruct.(fn{i})) && ~isempty(instruct.(fn{i}))
        fprintf(fid, '%s\n\t',fn{i});
        
        
        for j=1:length(instruct.(fn{i}))
            
            if j<length(instruct.(fn{i}))
                if isempty(instruct.(fn{i}){j})
                    fprintf(fid, '%s\n\t',' ');
                else
                    fprintf(fid, '%s\n\t',instruct.(fn{i}){j});
                end
            else
                if isempty(instruct.(fn{i}){j})
                    fprintf(fid, '%s\n',' ');
                else
                    fprintf(fid, '%s\n',instruct.(fn{i}){j});
                end
            end
        end
        
    elseif iscell(instruct.(fn{i})) && isempty(instruct.(fn{i}))
        fprintf(fid, '%s\n\t',fn{i});
        fprintf(fid, '%s\n',' ');

    elseif isnumeric(instruct.(fn{i}))
        fprintf(fid, '%s\n\t',fn{i});
        
        if ~(i==length(fn));
            if isempty(instruct.(fn{i}))
                %fprintf(fid, '%s\t',fn{i});
                fprintf(fid, '%s\n',' ');
            else
                %fprintf(fid, '%s\t',num2str(instruct.(fn{i})));
                fprintf(fid, '%s\n',num2str(instruct.(fn{i})));
            end
        end
        
    elseif ischar(instruct.(fn{i}))
        
        if ~isempty(instruct.(fn{i}))
            fprintf(fid, '%s\n\t',fn{i});
            fprintf(fid, '%s\n',instruct.(fn{i}));
            
        else
            fprintf(fid, '%s\n\t',fn{i});
            fprintf(fid, '%s\n',' ');
        end

    elseif isstruct(instruct.(fn{i}))
        
        fprintf(fid, '%s\n',fn{i});
        %print_report(instruct.(fn{i}),fn{i},fid);
        
    elseif islogical(instruct.(fn{i}))
        fprintf(fid, '%s\t',fn{i});
        fprintf(fid, '%s\t',num2str(instruct.(fn{i})));
        nl=1;
    end
    
    %if nl==1 || i==length(fn)
    if i==length(fn)
        fprintf(fid, '%s\n',' ');
        %nl=0;
    end
end

if nargin==1;
    fclose(fid);
end
end


