.com processdata.pro

window, 0
image_velocity, 'VELdcube_0.sav', 'Intermediate Velocity Cloud'
window, 1
image_velocity, 'VELdcube_1.sav', 'Low-Intermediate Velocity Cloud'
window, 2
image_velocity, 'VELdcube_2.sav', 'Low Velocity Cloud'

blink, [0, 1, 2], 1

wdelete, 0
wdelete, 1
wdelete, 2

a = get_kbrd()

image_coldens
