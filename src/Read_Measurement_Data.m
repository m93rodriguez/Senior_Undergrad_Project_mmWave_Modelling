%% Read Rappaport Data

Path=['D:\Dropbox\Trabajo de Grado\Codigo\Otros_Autores\NYU_Wireless\TCSL'...
    '_Clustering_160216\TCSL Clustering - 160216\Files\NYU data'];

Folder={'28_GHz_LOS','28_GHz_NLOS','73_GHz_LOS','73_GHz_NLOS'};

RMS=[];
for cont=1:length(Folder)
    L=dir([Path,'/',Folder{cont},'/*.xlsx']);
    L={L.name};
    for cont2=1:length(L)
        Archivo=[Path,'/',Folder{cont},'/',L{cont}];
        Data=xlsread(Archivo);
        
        Time=Data(:,1);
        Power=10.^(Data(:,2)/10);
        
        MeanTime=sum(Time.*Power)/sum(Power);
        RMS(end+1)=sqrt(sum((Time-MeanTime).^2.*Power)/sum(Power));
    end
end