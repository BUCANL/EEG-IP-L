mk_dataset_description; 
savejson('',dataset_description,'bids/dataset_description.json');
mk_participants;
cell2tsv('bids/participants.tsv',participants,'%s\t%d\n');
