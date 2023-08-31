
%{
    Questo script prende in ingresso l'EEG completo (6.42 min circa) di un
    determinato bambino/a e permette l'estrazione delle trials e il loro 
    salvataggio nelle relative (4) cartelle del bambino/a
%}


%STEP1: aprire eeglab e caricare l'EEG completo del bambino/a che ci
%interessa (cartella EEG_completo_per_ogni_candidato). Questo creerà la variabile EEG 
%che il codice utilizzerà

%STEP2: applicare filtro passa basso a 60Hz e passa alto a 2Hz insieme.
%Andare su tools->filter the data-> basic FIR e impostare nelle prime due
%celle 2 e 60 rispettivamente.

%STEP3: applicare il notch filter per rimuovere frequenze dovute alla
%circuiteria elettrica, quelle tra 45Hz e 55Hz. Andare su tools->filter the
%data -> basic FIR  e inserire nelle prime due celle 45 e 55
%rispettivamente, poi flaggare l'opzione "notch filter the data..."

%STEP 3.1: interpolazione

%{ 

    STEP4: ICA
Ecco gli step per la ICA:
•	Salvare il corrente dataset, quindi andare su   file->save current dataset. Io lo salvo su D:\...\EEG_completo_per_ogni_candidato\before_accept_ICA\LO0195.
Vedrai due file ma sono uguali, uno vale l'altro.
Questo è quello che ci interessa. E' il dataset PRIMA di applicare l'ICA.
Si carica facendo file->load current dataset

•	Se ICA non è mai stato avviato, andare su tools->run AMICA. In "In file" dai il percorso verso il dataset
.fdt salvato. In "Out Directory" metti il percorso (scegli D:\...\EEG_completo_per_ogni_candidato\before_accept_ICA\LO0195) dove ti creerà una cartella (amicaout).
    Se ICA è stato già fatto, allora in
    D:\...\EEG_completo_per_ogni_candidato\before_accept_ICA\LO0195\amicaout
    abbiamo già le componenti. Passare al punto successivo.

•	Dopo (anche 3 ore di attesa) andare su tools->post AMICA utility->load AMICA
components e inserire come path quello che porta alla cartella amicaout.
Questo caricherà le componenti. Infatti nella struttura EEG avremo 4 nuovi campi: icawinv, icasphere, icaweights, icachansind.


•	Avviare adjust e vedere quali artefatti propone di eliminare. Eliminare gli artefatti.
•	Adesso abbiamo un nuovo set eeg (in realta sia .set che .fdt) con le
componenti rimosse, D:\...after_accept_ICA\LO0195_after_ica_applied.set
•  fare il re-reference alla media.
•	Caricare questo nuovo dataset con eeglab


Step 5
- Estrarre le epoche e rimuovere la baseline
- clear
- Caricare questo nuovo dataset con eeglab

%}

%STEP4: codice bambino/bambina
codice_bambino = "LO0236_T24";
%inserire il path dove recuperare il file relativo dell'eye tracking
path_eye_tracking_file = "D:\Personal\Tesi_Magistrale\PARTE_1_ANALISI_STANDARD\EYE-tracking per ogni candidato\"+codice_bambino+".xlsx";

%questa funzione analizza il file eye-tracking relativo e restituisce la
%lista di indici degli stimoli non validi (es. se c'è 54 significa che il
%54-esimo stimolo, per esempio è DI40, non è valido)
not_valid_stimulus = get_trials_to_exclude(path_eye_tracking_file);

trials_sociale_sincrono = -1;
trials_sociale_asincrono = -1;
trials_non_sociale_sincrono = -1;
trials_non_sociale_asincrono = -1;

%numero di eventi presenti
num_events = size(EEG.event);
num_events = num_events(2);

%questo contatore "conta" il numero di stimoli processati
num_stimulus = 0;
%conta il numero di stimoli sociali sincroni totali
num_ss = 0;
%conta il numero di stimoli sociali asincroni totali
num_sa = 0;
%conta il numero di stimoli non sociali sincroni totali
num_nss = 0;
%conta il numero di stimoli non sociali asincroni totali
num_nsa = 0;

for i=1:num_events
    
    %se l'evento è iniziato (comprendiamo l'immagine ferma per la baseline
    %normalization), allora prendo da li ai successivi 3 secondi
    if EEG.event(i).type=="DIN8"
        start = EEG.event(i).latency;
        num_stimulus = num_stimulus + 1;
    end

    %se l'evento è sociale sincrono ed è valido
    if ( (EEG.event(i).type=="DI20" || EEG.event(i).type=="DI40") && ismember(num_stimulus,not_valid_stimulus)==false ) 
        fprintf("%d) Evento sociale sincrono \n",i);
        num_ss = num_ss+1;
        if trials_sociale_sincrono == -1
            trials_sociale_sincrono = double(EEG.data(1:128, start:(start+3000-1)));
        else
            trials_sociale_sincrono = [trials_sociale_sincrono, double(EEG.data(1:128, start:(start+3000-1)))];
        end

    end
    
    %se l'evento è sociale asincrono
    if ( (EEG.event(i).type=="DI30" || EEG.event(i).type=="DI50") && ismember(num_stimulus,not_valid_stimulus)==false )
        fprintf("%d) Evento sociale asincrono \n",i);
        num_sa = num_sa+1;
        if trials_sociale_asincrono == -1
            trials_sociale_asincrono = double(EEG.data(1:128, start:(start+3000-1)));
        else
            trials_sociale_asincrono = [trials_sociale_asincrono, double(EEG.data(1:128, start:(start+3000-1)))];
        end
    end

    %se l'evento è non sociale sincrono
    if ( (EEG.event(i).type=="DI60" || EEG.event(i).type=="DI80") && ismember(num_stimulus,not_valid_stimulus)==false ) 
        fprintf("%d) Evento non sociale sincrono \n",i);
        num_nss = num_nss+1;
        if trials_non_sociale_sincrono == -1
            trials_non_sociale_sincrono = double(EEG.data(1:128, start:(start+3000-1)));
        else
            trials_non_sociale_sincrono = [trials_non_sociale_sincrono, double(EEG.data(1:128, start:(start+3000-1)))];
        end
    end

    %se l'evento è non sociale asincrono
    if ( (EEG.event(i).type=="DI70" || EEG.event(i).type=="DI90") && ismember(num_stimulus,not_valid_stimulus)==false ) 
        fprintf("%d) Evento non sociale asincrono \n",i);
        num_nsa = num_nsa+1;
        if trials_non_sociale_asincrono == -1
            trials_non_sociale_asincrono = double(EEG.data(1:128, start:(start+3000-1)));
        else
            trials_non_sociale_asincrono = [trials_non_sociale_asincrono, double(EEG.data(1:128, start:(start+3000-1)))];
        end
    end
    
end

%Salvataggio delle epoche per categoria
mkdir("D:\Personal\Tesi_Magistrale\PARTE_1_ANALISI_STANDARD\dataset\"+codice_bambino+"\sociale_sincrono");
mkdir("D:\Personal\Tesi_Magistrale\PARTE_1_ANALISI_STANDARD\dataset\"+codice_bambino+"\sociale_asincrono");
mkdir("D:\Personal\Tesi_Magistrale\PARTE_1_ANALISI_STANDARD\dataset\"+codice_bambino+"\non_sociale_sincrono");
mkdir("D:\Personal\Tesi_Magistrale\PARTE_1_ANALISI_STANDARD\dataset\"+codice_bambino+"\non_sociale_asincrono");

path_ss = "D:\Personal\Tesi_Magistrale\PARTE_1_ANALISI_STANDARD\dataset\"+codice_bambino+"\sociale_sincrono\sociale_sincrono.mat";
path_sa = "D:\Personal\Tesi_Magistrale\PARTE_1_ANALISI_STANDARD\dataset\"+codice_bambino+"\sociale_asincrono\sociale_asincrono.mat";
path_ns = "D:\Personal\Tesi_Magistrale\PARTE_1_ANALISI_STANDARD\dataset\"+codice_bambino+"\non_sociale_sincrono\non_sociale_sincrono.mat";
path_na = "D:\Personal\Tesi_Magistrale\PARTE_1_ANALISI_STANDARD\dataset\"+codice_bambino+"\non_sociale_asincrono\non_sociale_asincrono.mat";

save(path_ss, 'trials_sociale_sincrono');
save(path_sa, 'trials_sociale_asincrono');
save(path_ns, 'trials_non_sociale_sincrono');
save(path_na, 'trials_non_sociale_asincrono');

%salvataggio di un file di log che descrive quanto fatto
fid = fopen('D:\Personal\Tesi_Magistrale\PARTE_1_ANALISI_STANDARD\dataset\'+codice_bambino+'\summary.txt','wt');
fprintf(fid, sprintf('Di seguito tutte le informazioni di sintesi di quanto ottenuto nello script trials_extractor.m\n\nInfo ad alto livello:\n Numero totali di stimoli processati:%d \n Numero totali di stimoli validi:%d \n\nInfo in dettaglio:\n Numero di epoche valide per SS: %d/16  \n Numero di epoche valide per SA: %d/16 \n Numero di epoche valide per NSS: %d/16  \n Numero di epoche valide per NSA: %d/16  \n\n Indici i-esimi degli stimoli non risultati validi: %s',num_stimulus,(num_ss+num_sa+num_nss+num_nsa),num_ss,num_sa,num_nss,num_nsa, num2str(not_valid_stimulus) ));
fclose(fid);
