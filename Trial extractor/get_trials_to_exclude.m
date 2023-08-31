
%{

    Questo codice legge il file tsv relativo all'eye-tracking e ritorna un
    array di indici di stimoli che sono da escludere perchè lo stimolo,
    quando in movimento, non è stato guardato per sufficiente tempo.

    La soglia decisa è di almeno 60ms.

%}


function stimulus_to_exclude = get_trials_to_exclude(path_eye_tracking_file)

    %{
        Dato che ogni riga si distacca dalla successiva di 3ms circa, allora
        desiderando un'osservazione/fissazione consecutiva di 60ms, vogliamo
        che il numero di righe sia 60/3 = 20; --> NEW 700ms -->233 righe
    %}
    consecutive_observation_threshold = 233; %OLD20;
    
    [num,txt,file_excel] = xlsread(path_eye_tracking_file);
    
    %numero righe da processare
    num_rows = size(txt);
    num_rows = num_rows(1);
    
    %colonne di interesse: Recording_timestamps, Presented Stimulus Name e AOI hit [TYPE:move]
    timestamp_column = 1;
    stimulus_name_column = 13;
    hit_move_column = 18;
    
    %conterrà il corrente nome dello stimolo
    stimulus_name_value = "";
    %serve solo per sapere se lo stimolo è nuovo
    new_stimulus = false;
    
    %tiene conto del numero di eventi scannerizzati (per una prova del 9)
    num_stimulus = 0; 
    
    %sarà la lista di stimoli da escludere
    stimulus_to_exclude = [];
    
    %conta il numero di osservazioni consecutive verso lo stimolo
    consecutive_observation = 0;
    
    %per ogni riga....
    for i=1:num_rows
    
       %se lo stimolo è uno degli 8
       stimulus_name_value = txt(i:i,stimulus_name_column:stimulus_name_column);
       
       if ( strcmp(stimulus_name_value,'NS_1.mp4') || strcmp(stimulus_name_value,'NS_2.mp4') || strcmp(stimulus_name_value,'NA_1.mp4') || strcmp(stimulus_name_value,'NA_2.mp4') || strcmp(stimulus_name_value,'SS_1.mp4') || strcmp(stimulus_name_value,'SS_2.mp4') || strcmp(stimulus_name_value,'SA_1.mp4') || strcmp(stimulus_name_value,'SA_2.mp4') )
        
            %se lo stimolo rispetto a prima è nuovo
            if new_stimulus == false
                num_stimulus = num_stimulus +1;
                new_stimulus = true;
                fprintf("riga: %d %s ",i, string(stimulus_name_value));
            end
    
            %se il bambino/a sta guardando lo stimolo
            if num(i:i,hit_move_column:hit_move_column) == 1 
                 consecutive_observation = consecutive_observation + 1;
            else %resetto
                 %solo però se non ha ancora superato la threshold
                 if consecutive_observation < consecutive_observation_threshold
                    consecutive_observation = 0;
                 end
            end
    
       %altrimenti lo stimolo non c'è oppure è terminato rispetto a prima
       %(quando c'era)
       else
        
           %però se prima lo stimolo esisteva, dobbiamo vedere se è stato
           %osservato a sufficienza
           if new_stimulus == true
                if consecutive_observation >= consecutive_observation_threshold
                    fprintf("valido %d \n", consecutive_observation);
                else
                    fprintf("non valido %d \n", consecutive_observation);
                    %lo aggiungo alla lista
                    stimulus_to_exclude = [stimulus_to_exclude,num_stimulus ];
                end
           end
    
           new_stimulus = false;
           consecutive_observation = 0;
       end
    
    end

end