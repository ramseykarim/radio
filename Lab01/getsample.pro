;+
;_____________________________________________________________________________
;NAME:     GETSAMPLE
;
;DESCRIPTION:
;          This function takes N samples via the GETPICO procedure and returns
;          them and their DFT.
;
;CALLING SEQUENCE: getsample(div, N, volt, /dual)
;
;INPUTS:
;          GETSAMPLE takes two arguments: div and N
;
;          DIV corresponds to the desired signal frequency and is passed
;          directly into the GETPICO procedure.
;          DIV relates to the signal frequency as:
;                 v sample = ( 62.5 / div ) MHz
;
;          N corresponds to the desired number of samples. It must be a
;          positive integer.
;          The GETPICO procedure called here takes a total of 16000 samples, so
;          N has an upper limit of 16000. N has a lower limit of 0, but we
;          stronly urge the use of at least one sample and highly recommend
;          using several.
;          GETSAMPLE uses the DFT procedure. The document for this routine
;          suggests that the sample number be a power of 2.
;
;          VOLT corresponds to the volt range that will be passed to
;          GETPICO. It should be a string matching the allowed inputs
;          of GETPICO. '2V', '1V', '500mV', '50mV' all work, as well
;          as others.
;
;KEYWORDS:
;          DUAL will add a 5th row to the DATA array corresponding to
;          the first N elements of another 16000 samples, this time
;          from the second input port of the picosampler.
;
;
;OUTPUTS:
;          GETSAMPLE returns a 2D array of 4xN elements.
;          The first row contains the N samples taken via getpico.
;          The second row contains the N time values at which samples were
;          taken, centered around 0.
;          The third row contains the N elements of the dft.
;          The fourth row contains the N frequency values used in calculating
;          the dft, centered around 0.
;          If DUAL is invoked, the fifth row will contain the first N
;          elements of the second sample set.
;
;
;
;Example:
;
;IDL> my_data = getsample(10, 1024, '1V', /DUAL)
;IDL> signal = my_data[*, 0]
;IDL> time_range = my_data[*, 1]
;IDL> voltage_spectrum = my_data[*, 2]
;IDL> frequency_range = my_data[*, 3]
;IDL> dualdata = my_data[*, 4]
;
;_____________________________________________________________________________
;-


function getsample, div, N, volt, dual=dual
  if not keyword_set(dual) then dual = 0
  vsamp = (62.5/div) * 10.^6
  getpico, volt, div, 1, tseries, vmult=vmult, dual=dual
  trange = (findgen(N) - (N/2))/(vsamp)
  signal = tseries[0:N-1]
  frange = (findgen(N)-(N/2))*(vsamp/N)
  dft, trange, signal, frange, vs

  data = [[signal*vmult], [trange], [vs], [frange]]
  
  if dual NE 0 then dualdata = tseries[0:N-1, 1]
  if dual NE 0 then data = [[data], [dualdata*vmult]]
  return, data
end

