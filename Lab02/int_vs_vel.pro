;+
;
;-


pro ivv

  restore, 'calib_spec_4096_6k.sav', desc=desc

  spec = calib_spec.spec
  N = calib_spec.n
  div = calib_spec.div
  samp = calib_spec.samp

  frange = (findgen(N)- N/2)*(62.5/div)/N

  fo = 0.4
  df = fo - frange
  c = 3 * 10.^5
  vrange = - (df/fo)*c

  plot, vrange, spec, title='Intensity vs Velocity for HI line', $
        xtitle=textoidl('Velocity (km s^{-1})'), $
        ytitle=textoidl('Intensity (K)'), psym=-4, $
        charsize=2, background=!white, color=!forest
end

