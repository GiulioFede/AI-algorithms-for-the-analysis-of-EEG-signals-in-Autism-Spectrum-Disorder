
%% Note: prima di eseguire
%{    
    1) Scaricare (deve essere sempre aggiornato) il file
    DB_FIA_EEG_Sperimentale in formato CSV. Assicurarsi che il campo Gruppo 
    col tipo a cui appartiene il bambino/a (es. LR) è presente per ogni bambino.
    Rinominarla in "tabella_riassuntiva_bambini.csv".
%}

%% Compilazione manuale di alcuni dati
%1) inserisci il numero di bambini che si processeranno (perchè alcuni non hanno passato il preprocessing)
num_child_to_process = 28;

%2) inserisci i codici dei bambini da processare (dovranno essere in numero quanto specificato in "num_child_to_process")
%NB: se qualche bambino non è stato poi più processato, NON includere il
%codice, quindi leggili direttamente dalla cartella ...\dataset
codici_bambini = ["LO0195", "LO0202", "LO0204", "LO0206", "LO0207", "LO0209", "LO0213","LO0214", "LO0215","LO0219","LO0222", "LO0223", "LO0230","LO0234", "LO0236","LO0239", "LO0242", "LO0243","LO0244","LO0249","LO0250", "LO0259", "LO0262", "LO0268","LO0291","LO0301","LO0311","LO0334"];

%3) dove sono presenti TUTTE le cartelle (finali) dei bambini 
base_root = "D:\Personal\Tesi_Magistrale\PARTE_1_ANALISI_STANDARD\dataset\";

group1 = 0;%HR_sign_no_sperim";
group2 = 0;%"HR_sign_sperim";
group3 = 1;%"HR_no_sign";
group4 = 2;%"LR";

LFP = ["LFP","RFP","LF","RF","LT","LP","RP","RT","LO","RO"];
bande = ["delta", "theta", "alpha", "beta", "low_gamma"];


%genero tutte le possibili combinazioni

etichette=string(zeros(1,55*5));
n=1;
for region_i=1:10

    switch region_i
        case 1
            labelri = "LFP";
        case 2
            labelri = "RFP";
        case 3
           labelri = "LF";
        case 4
           labelri = "RF";
        case 5
           labelri = "LT";
        case 6
           labelri = "LP";
        case 7
           labelri = "RP";
        case 8
           labelri = "RT";
        case 9
           labelri = "LO";
        otherwise
           labelri = "RO";
    end

    for region_j=1:10
        if(region_j>=region_i)
            switch region_j
                case 1
                    labelrj = "LFP";
                case 2
                    labelrj = "RFP";
                case 3
                   labelrj = "LF";
                case 4
                   labelrj = "RF";
                case 5
                   labelrj = "LT";
                case 6
                   labelrj = "LP";
                case 7
                   labelrj = "RP";
                case 8
                   labelrj = "RT";
                case 9
                   labelrj = "LO";
                otherwise
                   labelrj = "RO";
            end
            etichetta_delta = labelri+"_"+labelrj+"_delta";
            etichetta_theta = labelri+"_"+labelrj+"_theta";
            etichetta_alpha = labelri+"_"+labelrj+"_alpha";
            etichetta_beta = labelri+"_"+labelrj+"_beta";
            etichetta_low_gamma = labelri+"_"+labelrj+"_low_gamma";           
            etichette(n) = etichetta_delta;
            etichette(n+1) = etichetta_theta;
            etichette(n+2) = etichetta_alpha;
            etichette(n+3) = etichetta_beta;
            etichette(n+4) = etichetta_low_gamma;
            n= n+5;
        end
    end

end






ss_labels = cellfun(@(s) s+"_ss", etichette);
sa_labels = cellfun(@(s) s+"_sa", etichette);
nss_labels = cellfun(@(s) s+"_nss", etichette);
nsa_labels = cellfun(@(s) s+"_nsa", etichette);


riassunto = readtable("tabella_riassuntiva_bambini.csv");

groups2 = zeros(1,num_child_to_process);
groups = string(groups2);
for row=1: size(riassunto,1)

    code_child = cellstr(table2cell(riassunto(row,1)));
    index = find(codici_bambini==code_child);

    tipo =  cellstr(table2cell(riassunto(row,12)));

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


M = ["Codice","gruppo", "gruppo_codice", "tipo_stimolo1" ss_labels "tipo_stimolo2" sa_labels "tipo_stimolo3" nss_labels "tipo_stimolo4" nsa_labels];


%per ogni bambino/a
for index_child= 1: length(codici_bambini)
    codice_bambino = codici_bambini(index_child);
    gruppo_di_appartenenza = groups(index_child);
    codice_gruppo_di_appartenenza = groups2(index_child);
    riga_bambino = zeros(1,3+55*5*4+4);
    %per ogni stimolo...
    for stimolo_index = 1:length(stimoli)

        stimolo_label = stimoli(stimolo_index);
    

        A_delta = csvread(base_root+codice_bambino+"\"+stimolo_label+"\eeg_connectivity_analysis_results\imaginary_coherence\region_to_region_connectivity_delta.csv");
        A_theta = csvread(base_root+codice_bambino+"\"+stimolo_label+"\eeg_connectivity_analysis_results\imaginary_coherence\region_to_region_connectivity_theta.csv");
        A_alpha = csvread(base_root+codice_bambino+"\"+stimolo_label+"\eeg_connectivity_analysis_results\imaginary_coherence\region_to_region_connectivity_alpha.csv");
        A_beta = csvread(base_root+codice_bambino+"\"+stimolo_label+"\eeg_connectivity_analysis_results\imaginary_coherence\region_to_region_connectivity_beta.csv");
        A_low_gamma = csvread(base_root+codice_bambino+"\"+stimolo_label+"\eeg_connectivity_analysis_results\imaginary_coherence\region_to_region_connectivity_low_gamma.csv");
        m = zeros(1,55*5);
        n=1;
        for region_i=1:10
        
            for region_j=1:10
                if(region_j>=region_i)
                    
                    valore_delta = A_delta(region_i, region_j);
                    valore_theta = A_theta(region_i, region_j);
                    valore_alpha = A_alpha(region_i, region_j);
                    valore_beta = A_beta(region_i, region_j);
                    valore_low_gamma = A_low_gamma(region_i, region_j);         
                    m(n) = valore_delta;
                    m(n+1) = valore_theta;
                    m(n+2) = valore_alpha;
                    m(n+3) = valore_beta;
                    m(n+4) = valore_low_gamma;
                    n= n+5;
                end
            end
        
        end

        if stimolo_index==1
            disp(stimolo_index)
            riga_bambino = [codice_bambino  gruppo_di_appartenenza codice_gruppo_di_appartenenza stimolo_label  m] ;
        else
            disp(stimolo_index)
            riga_bambino = [riga_bambino stimolo_label m];
        end

    end
    

    M = [M; riga_bambino];
end

writematrix(M,"connectivity_per_region.xlsx");










