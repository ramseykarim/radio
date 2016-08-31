;+
;NAME:     SAVEDATA
;
;DESCRIPTION:
;          Saves the data from GETSAMPLE as a .sav file, conveniently
;          retaining important information for recordkeeping.
;
;CALLING SEQUENCE:
;          savedata, data, div, frequency, name
;
;INPUTS:
;          DATA expects the ouput from GETSAMPLE.
;
;          DIV expects the DIV argument passed to GETSAMPLE.
;
;          FREQUENCY expects the signal frequency. This is for
;          recordkeeping purposes. It is most useful as a string
;          or an integer.
;
;          NAME should be a string containing the desired name of the
;          .sav file.
;
;-

pro savedata, data, div, frequency, name
  vsamp = (62.5/div)*10.^6
  freq_str = strtrim(string(frequency), 1)
  vsamp_str = strtrim(string(vsamp), 1)
  save, data, FILENAME=name+'.sav', $
        DESCRIPTION='Data taken on '+systime()+' // signal F = '+freq_str+' // at sample frequency = '+vsamp_str
end
