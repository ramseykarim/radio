pro test, a, b, c
  N = 128
  nn = N/2
  arr1 = make_array(N, value=0)
  for i=nn-a,nn+a do arr1[i] = 1
  ft1 = FFT(arr1, /center)

  arr2 = make_array(128, value=0)
  for i=nn-b,nn+b do arr2[i] = 1
  ft2 = FFT(arr2, /center)

  arr3 = make_array(128, value=0)
  for i=nn-c,nn+c do arr3[i] = 1
  ft3 = FFT(arr3, /center)

  ps1 = ft1*conj(ft1)
  ps2 = ft2*conj(ft2)
  ps3 = ft3*conj(ft3)
  ps = ps1 + ps2 + ps3
  ftsum = ft1 + ft2 + ft3
  arrsum = arr1 + arr2 + arr3
  frange = findgen(N)-nn

;  window, 0
;  !p.multi = [0,1,3]
;  plot, frange, arr1, title='Test original 1', $
;        xtitle='Time'
;  plot, frange, arr2, title='Test original 2', $
;        xtitle='Time'
;  plot, frange, arr3, title='Test original 3', $
;        xtitle='Time'
;
;  window, 1
;  !p.multi = [0,1,3]
;  plot, frange, ft1, title='Test FT 1', $
;        xtitle='Frequency'
;  plot, frange, (ft1 + ft2), title='Test FT 1,2', $
;        xtitle='Frequency'
;  plot, frange, ftsum, title='Test FT 1,2,3', $
;        xtitle='Frequency'
;
;  window, 2
;  !p.multi = [0,1,3]
;  plot, frange, ps1, title='Test PS 1', $
;        xtitle='Frequency'
; plot, frange, (ps1 + ps2), title='Test PS 1,2', $
;        xtitle='Frequency'
  plot, frange, ps, title='Test PS 1,2,3', $
        xtitle='Frequency', charsize=2.5



end
