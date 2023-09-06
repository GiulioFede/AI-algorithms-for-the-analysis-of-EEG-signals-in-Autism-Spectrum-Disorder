%Questo script crea

%{ 
    %% Prima di runnare 
    
    1) Scaricare (deve essere sempre aggiornato) il file
    DB_FIA_EEG_Sperimentale in formato CSV. Assicurarsi che il campo Gruppo 
    col tipo a cui appartiene il bambino/a (es. LR) è presente per ogni bambino.
    Rinominarla in "tabella_riassuntiva_bambini.csv".

    2) Aprire eeglab e aprire qualsiasi dataset (es.
    ...\EEG_completo_per_ogni_candidato\LO0311\2.final\LO0311.set) cosi da
    caricare la variabile EEG

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


x = [EEG.chanlocs.X];
y = [EEG.chanlocs.Y];

map = [0,0,81;
3,0,84;
6,0,87;
9,0,89;
12,0,92;
15,0,95;
18,0,98;
21,0,100;
24,0,103;
27,0,106;
30,0,109;
33,0,111;
36,0,114;
39,0,117;
42,0,119;
45,0,122;
48,0,125;
51,0,128;
54,0,130;
57,0,133;
60,0,136;
63,0,139;
66,0,141;
69,0,144;
72,0,147;
75,0,150;
78,0,152;
81,0,155;
85,0,158;
88,0,161;
91,0,163;
94,0,166;
97,0,169;
100,0,172;
103,0,174;
106,0,177;
109,0,180;
112,0,182;
115,0,185;
118,0,188;
121,0,191;
124,0,193;
127,0,196;
130,0,199;
133,0,202;
136,0,204;
139,0,207;
142,0,210;
145,0,213;
148,0,215;
151,0,218;
154,0,221;
157,0,224;
160,0,226;
163,0,229;
166,0,232;
169,0,235;
172,0,237;
175,0,240;
178,0,243;
181,0,245;
184,0,248;
187,0,251;
190,0,254;
193,0,255;
194,0,252;
195,0,248;
196,0,245;
197,0,242;
198,0,238;
199,0,235;
200,0,232;
201,0,228;
202,0,225;
203,0,221;
204,0,218;
205,0,215;
206,0,211;
207,0,208;
208,0,205;
209,0,201;
210,0,198;
211,0,195;
212,0,191;
213,0,188;
214,0,185;
215,0,181;
216,0,178;
217,0,175;
218,0,171;
219,0,168;
219,0,165;
220,0,161;
221,0,158;
222,0,155;
223,0,151;
224,0,148;
225,0,145;
226,0,141;
227,0,138;
228,0,135;
229,0,131;
230,0,128;
231,0,124;
232,0,121;
233,0,118;
234,0,114;
235,0,111;
236,0,108;
237,0,104;
238,0,101;
239,0,98;
240,0,94;
241,0,91;
242,0,88;
243,0,84;
244,0,81;
245,0,78;
246,0,74;
247,0,71;
248,0,68;
249,0,64;
250,0,61;
251,0,58;
252,0,54;
253,0,51;
254,0,48;
255,0,44;
255,2,42;
255,6,42;
255,10,41;
255,14,40;
255,18,40;
255,22,39;
255,26,38;
255,30,38;
255,34,37;
255,38,37;
255,42,36;
255,46,35;
255,50,35;
255,54,34;
255,58,34;
255,62,33;
255,66,32;
255,70,32;
255,74,31;
255,78,30;
255,82,30;
255,86,29;
255,90,29;
255,94,28;
255,98,27;
255,102,27;
255,106,26;
255,110,25;
255,114,25;
255,118,24;
255,122,24;
255,126,23;
255,130,22;
255,134,22;
255,138,21;
255,142,21;
255,146,20;
255,150,19;
255,154,19;
255,158,18;
255,162,17;
255,167,17;
255,171,16;
255,175,16;
255,179,15;
255,183,14;
255,187,14;
255,191,13;
255,195,13;
255,199,12;
255,203,11;
255,207,11;
255,211,10;
255,215,9;
255,219,9;
255,223,8;
255,227,8;
255,231,7;
255,235,6;
255,239,6;
255,243,5;
255,247,4;
255,251,4;
255,255,3;
255,255,6;
255,255,10;
255,255,14;
255,255,18;
255,255,22;
255,255,26;
255,255,30;
255,255,34;
255,255,38;
255,255,42;
255,255,46;
255,255,50;
255,255,54;
255,255,58;
255,255,62;
255,255,66;
255,255,69;
255,255,73;
255,255,77;
255,255,81;
255,255,85;
255,255,89;
255,255,93;
255,255,97;
255,255,101;
255,255,105;
255,255,109;
255,255,113;
255,255,117;
255,255,121;
255,255,125;
255,255,129;
255,255,133;
255,255,137;
255,255,141;
255,255,145;
255,255,149;
255,255,153;
255,255,157;
255,255,161;
255,255,165;
255,255,169;
255,255,173;
255,255,176;
255,255,180;
255,255,184;
255,255,188;
255,255,192;
255,255,196;
255,255,200;
255,255,204;
255,255,208;
255,255,212;
255,255,216;
255,255,220;
255,255,224;
255,255,228;
255,255,232;
255,255,236;
255,255,240;
255,255,244;
255,255,248;
255,255,252;
255,255,255];

map = map ./ 255;

group1 = "2";%HR_sign_no_sperim";
group2 = "2";%"HR_sign_sperim";
group3 = "1";%"HR_no_sign";
group4 = "0";%"LR";

riassunto = readtable("tabella_riassuntiva_bambini.csv");
groups = zeros(1,num_child_to_process);
groups_names = zeros(1,num_child_to_process);
groups_names = string(groups_names);

%per ogni riga della tabella riassuntiva...
for row=1: size(riassunto,1)
    fprintf("Elaboro riga %i\n", row);

    %estraggo codice bambino (es. LO0219) 
    code_child = cellstr(table2cell(riassunto(row,1)));
    %nell'array in cui ho inserito manualmente i codici, estraggo l'indice dove il codice code_child è presente
    index = find(codici_bambini==code_child);

    %estraggo il gruppo di appartenenza (es. LR)
    tipo =  cellstr(table2cell(riassunto(row,12)));
    disp(tipo);
    disp(index)
    l = "";
    if tipo == "LR"
        t = 2;
        l = "LR";
    elseif tipo == "HR_no_sign"
        t = 1;
        l = "HR_no_sign";
    else %utilizzo questo caso per HR_sign cosi da prendermi sia gli _sperim che i no_sperim (sono sempre HR_sign)
        t = 0;
        l = "HR_sign";
    end

    groups(index) = t;
    groups_names(index)=l;

end


stimoli= ["sociale_sincrono", "sociale_asincrono", "non_sociale_sincrono", "non_sociale_asincrono"];

n = 0;
info_db = [];

%per ogni stimolo...
for stimolo_i=1:length(stimoli)

    stimolo = stimoli(stimolo_i);

    %creo cartella per lo stimolo corrente
    mkdir("dataset_topoplots\"+stimolo);

    for child_i=1:length(codici_bambini)
        
        %prendo un bambino di quelli dell'array prima creato
        codice_bambino = codici_bambini(child_i);
        %prendo (codice numerico) del suo gruppo di appartenenza
        gruppo = groups(child_i);

        if gruppo == 0
            gruppo = "LR";
        elseif gruppo == 1
            gruppo = "HR_no_sign";
        else
            gruppo = "HR_sign";
        end

        values_per_channel = csvread(base_root+codice_bambino+"\"+stimolo+"\eeg_power_analysis_results\egg_power_per_channel.csv");
        
        for figur = 1: 5
            figure(2),clf
            topoplotIndie_mod(values_per_channel(:,figur), EEG.chanlocs);
            caxis([0 1]);
            colormap(map)
            F = getframe(gcf);
            [X, Map] = frame2im(F);
            topo = X(36:366,125:455,:);
            save("dataset_topoplots\"+stimolo+"\"+num2str(n)+".mat","topo");
            n = n+1;
            banda = "delta";
            if figur==1
                banda = "delta";
            elseif figur==2
                banda="theta";
            elseif figur==3
                banda="alpha";
            elseif figur==4
                banda="beta";
            else
                banda="low_gamma";
            end
            info_db = [info_db; codice_bambino gruppo banda n ];
        end



    end

    writematrix(info_db,"dataset_topoplots\"+"info_dataset"+"_"+stimolo+".csv");
    info_db = [];
    n = 0;
end

writematrix(groups_names,"groups.csv");

%{
figure(3),clf
topoplotIndie_mod(values(:,2), EEG.chanlocs);
caxis([0 1]);
colormap(map)
F = getframe(gcf);
figure(4),clf
[X, Map] = frame2im(F);

imshow(X(36:366,125:455,:))
save("prova.mat","X")
%}