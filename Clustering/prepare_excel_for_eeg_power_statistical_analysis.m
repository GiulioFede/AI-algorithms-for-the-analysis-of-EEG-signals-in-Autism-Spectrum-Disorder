%scegli stimolo
tipo_stimolo = "sociale_sincrono";

codici_bambini = ["LO0195", "LO0202", "LO0204", "LO0206", "LO0207", "LO0209", "LO0213","LO0214", "LO0215","LO0222", "LO0223", "LO0230", "LO0236","LO0239", "LO0242", "LO0243","LO0249","LO0250", "LO0262", "LO0268"];
group1 = 0;%HR_sign_no_sperim";
group2 = 0;%"HR_sign_sperim";
group3 = 1;%"HR_no_sign";
group4 = 2;%"LR";

labels = ["Codice","gruppo", "gruppo_codice"," tipo stimolo1", "Left Frontopolar (delta)", "Left Frontopolar (theta)", "Left Frontopolar (alpha)", "Left Frontopolar (beta)", "Left Frontopolar (low gamma)",...
    "Right Frontopolar (delta)", "Right Frontopolar (theta)", "Right Frontopolar (alpha)", "Right Frontopolar (beta)", "Right Frontopolar (low gamma)",...
    "Left Frontal (delta)", "Left Frontal (theta)", "Left Frontal (alpha)", "Left Frontal (beta)", "Left Frontal (low gamma)",...
    "Right Frontal (delta)", "Right Frontal (theta)", "Right Frontal (alpha)", "Right Frontal (beta)", "Right Frontal (low gamma)",...
    "Left Temporal (delta)", "Left Temporal (theta)", "Left Temporal (alpha)", "Left Temporal (beta)", "Left Temporal (low gamma)",...
    "Left Paretial (delta)", "Left Paretial (theta)", "Left Paretial (alpha)", "Left Paretial (beta)", "Left Paretial (low gamma)",...
    "Right Paretial (delta)", "Right Paretial (theta)", "Right Paretial (alpha)", "Right Paretial (beta)", "Right Paretial (low gamma)",...
    "Right Temporal (delta)", "Right Temporal (theta)", "Right Temporal (alpha)", "Right Temporal (beta)", "Right Temporal (low gamma)",...
    "Left Occipital (delta)", "Left Occipital (theta)", "Left Occipital (alpha)", "Left Occipital (beta)", "Left Occipital (low gamma)",...
    "Right Occipital (delta)", "Right Occipital (theta)", "Right Occipital (alpha)", "Right Occipital (beta)", "Right Occipital (low gamma)"];


ss_labels = cellfun(@(s) s+"_ss", labels(5:end));
sa_labels = cellfun(@(s) s+"_sa", labels(5:end));
nss_labels = cellfun(@(s) s+"_nss", labels(5:end));
nsa_labels = cellfun(@(s) s+"_nsa", labels(5:end));


riassunto = readtable("tabella_riassuntiva_bambini.csv");

groups2 = zeros(1,20);
groups = string(groups2);
for row=1: size(riassunto,1)

    code_child = cellstr(table2cell(riassunto(row,1)));
    index = find(codici_bambini==code_child);

    tipo =  cellstr(table2cell(riassunto(row,12)));
    disp(tipo);
    if tipo == "LR"
        t = 2;
        group = "LR";
    elseif tipo == "HR_no_sign"
        t = 1;
        group = "HR_no_sign";
    else
        t = 0;
        group = "HR_sign";
    end

    groups2(index) = t;
    groups(index) = group;

end


stimoli= ["sociale_sincrono", "sociale_asincrono", "non_sociale_sincrono", "non_sociale_asincrono"];

base_root = "D:\Personal\Tesi_Magistrale\PARTE_1_ANALISI_STANDARD\dataset\";
M = ["Codice","gruppo", "gruppo_codice", "tipo_stimolo1" ss_labels "tipo_stimolo2" sa_labels "tipo_stimolo3" nss_labels "tipo_stimolo4" nsa_labels];


%per ogni bambino/a
for index_child= 1: length(codici_bambini)
    codice_bambino = codici_bambini(index_child);
    gruppo_di_appartenenza = groups(index_child);
    codice_gruppo_di_appartenenza = groups2(index_child);
    m = [];
    %per ogni stimolo...
    for stimolo_index = 1:length(stimoli)

        stimolo_label = stimoli(stimolo_index);
    
        %carico file di potenza per regione (è una matrice 5 x 10 dove ogni
        %cella (i,j) indica il valore di potenza della j-esima regione
        %sulla banda i-esima
        A = csvread(base_root+codice_bambino+"\"+stimolo_label+"\eeg_power_analysis_results\egg_power_per_region.csv");

        if stimolo_index==1
            disp(stimolo_index)
            m = [codice_bambino  gruppo_di_appartenenza codice_gruppo_di_appartenenza stimolo_label  A(:,1)' A(:,2)' A(:,3)' A(:,4)' A(:,5)' A(:,6)' A(:,7)' A(:,8)' A(:,9)' A(:,10)'] ;
        else
            disp(stimolo_index)
            m = [m  stimolo_label  A(:,1)' A(:,2)' A(:,3)' A(:,4)' A(:,5)' A(:,6)' A(:,7)' A(:,8)' A(:,9)' A(:,10)'];
        end

    end

    M = [M; m];
end

writematrix(M,"power_per_region3.xls");
