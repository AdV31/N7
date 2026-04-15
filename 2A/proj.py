#Sebastian Lague 3aids: video banc de poisson
#trouver bibliothèque affichage temps réel python (ex: pygame, ...)
#les particule doivent pouvoir être soumis à des forces extérieures (ex: courir vers la sortie, aller vers la nourriture, ...)

import numpy as np

class point:
    def __init__(self,x,y,vx,vy,masse,rayon,axe=(0,1)):
        self.x = x
        self.y = y
        self.vx = vx
        self.vy = vy
        self.masse = masse
        self.rayon = rayon
        self.couleur = "noir"
        self.axe = axe  #normé

    def get_x(self):
        return self.x

    def set_x(self, value):
        self.x = value

    def get_y(self):
        return self.y

    def set_y(self, value):
        self.y = value

    def get_vx(self):
        return self.vx

    def set_vx(self, value):
        self.vx = value

    def get_vy(self):
        return self.vy

    def set_vy(self, value):
        self.vy = value

    def get_masse(self):
        return self.masse

    def set_masse(self, value):
        self.masse = value

    def get_rayon(self):
        return self.rayon

    def set_rayon(self, value):
        self.rayon = value

    def get_couleur(self):
        return self.couleur

    def set_couleur(self, value):
        self.couleur = value

    def get_axe(self):
        return self.axe

    def set_axe(self, value):
        self.axe = value
    
    def normaliser (axe):
        norm = sqrt(self.axe[0]^2 + self.axe[1]^2)
        return axe/norm

    def bouger(dx, dy, dvx, dvy, daxe=(0,0)):
        self.x += dx
        self.y += dy
        self.vx += dvx
        self.vy += dvy
        normaliser(daxe)
        self.axe = daxe


# a mettre dans l'autre, general (changer les self et rajouter la meme formule de csqce pour l'autre point)
def detection_collision(p):
    somme_rayon = p.get_rayon() + self.rayon
    dist = sqrt((self.x - p.get_x())^2 + (self.y - p.get_y()))^2
    return dist <= somme_rayon

def csqce_collision(p, dt):
    m1 = self.masse
    m2 = p.get_masse()
    v1x = self.vx
    v1y = self.vy
    v2x = p.get_vx()
    v2y = p.get_vy()
    vx = (2*m2*v2x + (m1-m2)*v1x)/(m1+m2)
    vy = (2*m2*v2y + (m1-m2)*v1y)/(m1+m2)
    dx = vx*dt
    dy = vy*dt





def voisin_rayon(p,r,listePoints):
    v = []

    x,y = p.x,p.y
    xmin = x-r if x-r >= 0 else 0
    xmax = x+r if x+r < max_x else max_x
    ymin = y-r if y-r >= 0 else 0
    ymax = y+r if y+r < max_y else max_y

    for i in range(xmin,xmax+1):
        for j in range(ymin,ymax+1):
            if (i,j) != (x,y) and (i,j) in listePoints:
                v.append((i,j))
    return v

def densite(p, r, listePoints):
    d = 0
    v = voisin_rayon(p, r, listePoints)
    d = len(v)/len(listePoints)
    return d

def interaction(p,listePoints,dt=1):
    fx,fy = 0,0
    fvx,fvy = 0,0
    d = densite(p,listePoints)
    match d:
        case 1:
            fx,fy = 0,0
            fvx,fvy = 0,0
        case _:
            fx,fy = 0,0
            fvx,fvy = 0,0

    point = [p.x + fx, p.y + fy, p.vx + fvx, p.vy + fvy]

    return point

def update(listePoints):
    new_Ensemble = []
    dt = 1
    for p in listePoints:
        point = interaction(p,listePoints,dt)
        p_new = point(point[0],point[1],point[2],point[3])
        new_listePoints.append(p_new)
    return new_listePoints

def main():
    listePoints = [(0,0),(0,1),(1,0),(1,1)]
    
    global max_x, max_y
    max_x = np.max([pt[0] for pt in listePoints]) + 1
    max_y = np.max([pt[1] for pt in listePoints]) + 1

    nb_updates = 10
    while nb_updates > 0:
        listePoints = update(listePoints)
        print(listePoints)
        nb_updates -= 1