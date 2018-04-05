% tree_new() - returns a new blank tree structure that has methods that allow
%              operations on the tree
%
% Usage:
%   >>  tree = tree_new();
%   >>  [element] = tree.get(tree, elementid)
%   >>  [tree, node] = tree.add(tree, parent, element)
%   >>  [tree] = tree.remove(tree, elementid)
%   >>  [children] = tree.get_children(tree, elementid);
%   >>  [tree] = tree.garbage_collect();
%          - cleans the tree structure if necessary
%   
%
% Inputs:
%   tree     - the tree structure
%   element  - the element to be stored
%   elementid- target element id
%   parent   - the element id of the parent
%    
% Outputs:
%   tree     - the tree structure with member functions
%   element  - stored element in the tree
%   node     - element id of the new node
%   children - cell array of children element ids
%

% Copyright (C) 2017 Brock University Cognitive and Affective Neuroscience Lab
%
% Code written by Brad Kennedy
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program (LICENSE.txt file in the root directory); if not, 
% write to the Free Software Foundation, Inc., 59 Temple Place,
% Suite 330, Boston, MA  02111-1307  USA


function res = tree_new()
    res = struct();

    % Used elements
    res.numelements = 0;
    % Storage for elements
    res.elements = {};

    root = new_node();
    res.elements{end+1} = root;
    res.numelements = 1;

    res.get = @tree_get;
    res.add = @tree_add;
    res.remove = @tree_remove;
    res.get_children = @tree_get_children;
    res.garbage_collect = @tree_garbage_collect;
    res.get_children_contents_of_match = @tree_get_children_contents_of_match;
end

function [element] = tree_get(tree, elementid)
    if nargin ~= 2
        error('You need 2 arguments for tree_get');
    end
    tree_exists(tree, elementid);
    if iscell(elementid)
        element = cellfun(@(x) x.element, ...
            tree.elements(cell2mat(elementid)), 'UniformOutput', false);
        return
    end
    element = tree.elements{elementid}.element;
end

function [tree, node] = tree_add(tree, parent, element)
    if nargin ~= 3
        error('You need 3 arguments for tree_add');
    end
    tree_exists(tree, parent);

    nnode = new_node();
    % end+1
    node = numel(tree.elements)+1;
    tree.elements{parent}.children{end+1} = node;
    nnode.element = element;
    tree.elements{node} = nnode;
    tree.numelements = tree.numelements + 1;
end

function [tree] = tree_remove(tree, element)
    error('Not yet implemented');
end

function [children] = tree_get_children(tree, element)
    if nargin ~= 2
        error('You need 2 arguments for tree_get_children');
    end
    children = tree.elements{element}.children;
end

function [elements] = tree_get_children_contents_of_match(tree, ...
        comparator, parent)
    potchildren = tree.get_children(tree, parent);
    potchildren = potchildren(arrayfun(comparator, tree.get(tree, potchildren)));
    if numel(potchildren) == 0
        elements = {};
        return;
    end
    if numel(potchildren) ~= 1
        error('potential children not unique');
    end
    % Get children numbers
    cid = tree.get_children(tree, potchildren{1});
    elements = tree.get(tree, cid);
end

function [tree] = tree_garbage_collect()
    error('Not yet implemented');
end

function tree_exists(tree, element)
    % Verify element (a number) exists in the tree
    if iscell(element)
        for i=1:numel(element)
            if numel(tree.elements) >= element{i} ... 
                    && isempty(tree.elements{element{i}})
                error(sprintf('element %d is not in tree', element{i}));
            end
        end
    else
        if numel(tree.elements) >= element && isempty(tree.elements{element})
            error(sprintf('element %d is not in tree', element));
        end
    end
end

function [treenode] = new_node()
    treenode = struct();
    treenode.children = {};
    treenode.element = [];
end

