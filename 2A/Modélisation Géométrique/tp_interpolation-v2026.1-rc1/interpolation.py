
import math
import numpy as np
from typing import List, Tuple


#####################################################
############## Lagrange functionnal setting #########
#####################################################

def lagrange(YY: List[float], TT: List[float], t: float) -> float:
    """Calculate Lagrange interpolation for a given point.

    Args:
        YY (List[float]): The y-coordinates of the data points.
        TT (List[float]): The x-coordinates of the data points.
        t (float): The point at which to evaluate the interpolated polynomial.

    Returns:
        float: The interpolated value at point t.
    """

    l = [0 for i in range(len(TT))]
    for i in range(len(TT)):
        ti = TT[i]
        prod = 1
        for j in range(len(TT)):
            tj = TT[j]
            if (i != j) :
                prod = prod * ((t - tj)/(ti - tj))
        l[i] = prod
    L = np.asarray(l)
    Y = np.asarray(YY)
    return np.dot(np.transpose(Y),L)


#####################################################
############## Neville's algorithm ##################
#####################################################


def neville(YY:np.ndarray, TT: np.ndarray, t: float) -> float:
    """
    Perform polynomial interpolation using Neville's algorithm.

    Args:
        YY (np.ndarray): The y-coordinates of the data points.
        TT (np.ndarray): The times where datapoints are interpolated.
        t (float): The value at which the interpolation is calculated.

    Returns:
        float: The interpolated value at x.
    """
    n = len(TT)
    P = [YY[i] for i in range(len(YY))]
    for j in range(1,n):
        for i in range(n-j):
            P[i] = ((TT[i+j]-t)*P[i]+(t - TT[i])*P[i+1])/(TT[i+j] - TT[i])
    return P[0]

#####################################################
################ Time sampling ######################
#####################################################



def tchebycheff_parametrisation(nb_point: int) -> List[float]:
    """
    Compute the Tchebycheff abscissas for a given number of points (from -1 to 1).

    Args:
        nb_point (int): The number of points for which the Tchebycheff abscissas must be computed.

    Returns:
        List[float]: A list containing the Tchebycheff abscissas.
    """

    # TDOO









    return [0,1]



def regular_parametrisation(nb_point: int) -> List[float]:
    """
    Create regular subdivision with the first point at 0 and the last at 1.

    Args:
        nb_point (int): The number of points for which regular abscissas are calculated.

    Returns:
        List[float]: A list containing the regular abscissas.
    """

    Ind = [(i/(nb_point-1)) for i in range(nb_point)]

    return Ind

def distance_parametrisation(XX: List[float], YY: List[float]) -> List[float]:
    """
    Create subdivision where spacing between points is proportional to their distance in R2,
    with the first point at 0 and the last at 1.

    Args:
        XX (List[float]): The X coordinates of the points.
        YY (List[float]): The Y coordinates of the points.

    Returns:
        List[float]: A list containing the abscissas proportional to the distances.
    """
    n = len(XX)
    X = np.array(XX)
    Y = np.array(YY)
    Ind = np.zeros((n,1))
    Ind[1:n] = np.sqrt(np.square((X[0:n-1]-X[1:n]))+np.square((Y[0:n-1]-Y[1:n])))
    Ind = np.cumsum(Ind)
    Ind = Ind*(1/Ind[n-1])
    return Ind



def parametrisation_racinedistance(XX: List[float], YY: List[float]) -> List[float]:
    """
    Create subdivision where spacing between points is proportional to the square root of their distance in R2,
    with the first point at 0 and the last at 1.

    Args:
        XX (List[float]): The X coordinates of the points.
        YY (List[float]): The Y coordinates of the points.

    Returns:
        List[float]: A list containing the abscissas proportional to the square roots of the distances.
    """

    n = len(XX)
    Ind = np.zeros((n,1))
    X = np.array(XX)
    Y = np.array(YY)
    Ind[1:n] = np.sqrt(np.sqrt(np.square((X[0:n-1]-X[1:n]))+np.square((Y[0:n-1]-Y[1:n]))))
    Ind = np.cumsum(Ind)
    Ind = Ind*(1/Ind[n-1])
    return Ind





#####################################################
############ Neville's Algorithm @@@@ ###############
#####################################################

def neville_param(XX, YY, TT, list_tt) -> Tuple[List[float], List[float]]:
    """
    Interpolate points using Neville's algorithm for given x and y coordinates.

    Args:
        XX (list[float]): The x-coordinates of the data points.
        YY (list[float]): The y-coordinates of the data points.
        TT (list[float]): The time points corresponding to the data points.
        list_tt (list[float]): The time points at which to evaluate the interpolation.

    Returns:
        tuple: Two lists containing the interpolated x and y coordinates.
    """

    # TODO




    return [1], [1]


def surface_interpolation_neville(X, Y, Z, TT_x,TT_y, list_tt, nb_points_x) -> np.ndarray:
    """
    Interpolates a surface at given time points using Neville's interpolation method.

    Args:
        X (np.ndarray): X coordinates of 3D points (shape: (nb_points_x, len(TT_y))).
        Y (np.ndarray): Y coordinates of 3D points (shape: (nb_points_x, len(TT_y))).
        Z (np.ndarray): Z coordinates of 3D points (shape: (nb_points_x, len(TT_y))).
        TT_x (List[float]): Times corresponding to the points in X.
        TT_y (List[float]): Times corresponding to the points in Y.
        list_tt (List[float]): Times at which to evaluate the interpolated surface.
        nb_points_x (int): Number of points in the grid for interpolation.

    Returns:
        np.ndarray: Interpolated surface (shape: (len(list_tt), len(list_tt), 3)).
    """
    
    n = len(list_tt)
    interpolated_surface_1 = np.zeros((nb_points_x, n, 3))  # Intermediate surface
    interpolated_surface = np.zeros((n, n, 3))  # Final interpolated surface

    # TODO
















    return interpolated_surface