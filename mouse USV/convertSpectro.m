function convertSpectro(wavFile, matFile)

warning off;

%% set params and generate spectrogram
sngparms.plot = true;
sngparms.threshold = 1*10^4;
sngparms.nfreq = 512;
sngparms.freqrange = [25000 110000];
sngparms.memmax = 50*1024*1024;
sound2sng(wavFile,sngparms,matFile);
