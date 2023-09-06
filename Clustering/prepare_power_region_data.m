
%% Compilazione manuale
%1) scegli stimolo
tipo_stimolo = "sociale_sincrono";
%2) indica il nome del file da salvare
file_name = "clustering_power_dataset_ss.csv";
%2) inserisci il numero di bambini che si processeranno (perchè alcuni non hanno passato il preprocessing)
num_child_to_process = 28;
%3) inserisci i codici dei bambini da elaborare (quelli della cartella ../dataset)
codici_bambini = ["LO0195", "LO0202", "LO0204", "LO0206", "LO0207", "LO0209", "LO0213","LO0214", "LO0215","LO0219","LO0222", "LO0223", "LO0230","LO0234", "LO0236","LO0239", "LO0242", "LO0243","LO0244","LO0249","LO0250", "LO0259", "LO0262", "LO0268","LO0291","LO0301","LO0311","LO0334"];
%4) indica il path di base dove poi saranno contenute tutte le cartelle dei bambini 
base_root = "D:\Personal\Tesi_Magistrale\PARTE_1_ANALISI_STANDARD\dataset\";

group1 = 0;%HR_sign_no_sperim";
group2 = 0;%"HR_sign_sperim";
group3 = 1;%"HR_no_sign";
group4 = 2;%"LR";

labels = ["Codice","gruppo", "gruppo_codice"," tipo stimolo", "Left Frontopolar (delta)", "Left Frontopolar (theta)", "Left Frontopolar (alpha)", "Left Frontopolar (beta)", "Left Frontopolar (low gamma)",...
    "Right Frontopolar (delta)", "Right Frontopolar (theta)", "Right Frontopolar (alpha)", "Right Frontopolar (beta)", "Right Frontopolar (low gamma)",...
    "Left Frontal (delta)", "Left Frontal (theta)", "Left Frontal (alpha)", "Left Frontal (beta)", "Left Frontal (low gamma)",...
    "Right Frontal (delta)", "Right Frontal (theta)", "Right Frontal (alpha)", "Right Frontal (beta)", "Right Frontal (low gamma)",...
    "Left Temporal (delta)", "Left Temporal (theta)", "Left Temporal (alpha)", "Left Temporal (beta)", "Left Temporal (low gamma)",...
    "Left Paretial (delta)", "Left Paretial (theta)", "Left Paretial (alpha)", "Left Paretial (beta)", "Left Paretial (low gamma)",...
    "Right Paretial (delta)", "Right Paretial (theta)", "Right Paretial (alpha)", "Right Paretial (beta)", "Right Paretial (low gamma)",...
    "Right Temporal (delta)", "Right Temporal (theta)", "Right Temporal (alpha)", "Right Temporal (beta)", "Right Temporal (low gamma)",...
    "Left Occipital (delta)", "Left Occipital (theta)", "Left Occipital (alpha)", "Left Occipital (beta)", "Left Occipital (low gamma)",...
    "Right Occipital (delta)", "Right Occipital (theta)", "Right Occipital (alpha)", "Right Occipital (beta)", "Right Occipital (low gamma)"];

riassunto = readtable("tabella_riassuntiva_bambini.csv");

groups2 = zeros(1,num_child_to_process);
for row=1: size(riassunto,1)

    code_child = cellstr(table2cell(riassunto(row,1)));
    index = find(codici_bambini==code_child);

    tipo =  cellstr(table2cell(riassunto(row,12)));
    disp(tipo);
    if tipo == "LR"
        t = 2;
    elseif tipo == "HR_no_sign"
        t = 1;
    else
        t = 0;
    end

    groups2(index) = t;

end


M = [labels];
%per ogni bambino/a
for index_child= 1: length(codici_bambini)

    codice_bambino = codici_bambini(index_child);
    gruppo_di_appartenenza_codice = groups2(index_child);
    group1 = 0;%HR_sign_no_sperim";
    group2 = 0;%"HR_sign_sperim";
    group3 = 1;%"HR_no_sign";
    group4 = 2;%"LR"

    if gruppo_di_appartenenza_codice == 1
        gruppo_di_appartenenza = "HR_no_sign";
    elseif gruppo_di_appartenenza_codice == 2
        gruppo_di_appartenenza = "LR";
    else
        gruppo_di_appartenenza = "HR_sign";
    end

    %carico file di potenza per regione (è una matrice 5 x 10 dove ogni
    %cella (i,j) indica il valore di potenza della j-esima regione
    %sulla banda i-esima
    A = csvread(base_root+codice_bambino+"\"+tipo_stimolo+"\eeg_power_analysis_results\egg_power_per_region.csv");

    M = [M; codice_bambino gruppo_di_appartenenza gruppo_di_appartenenza_codice tipo_stimolo A(:,1)' A(:,2)' A(:,3)' A(:,4)' A(:,5)' A(:,6)' A(:,7)' A(:,8)' A(:,9)' A(:,10)'];

end

writematrix(M,file_name);
