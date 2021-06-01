"""
Fisher Discriminant Ratio
code by Hangwei Qian
Aug.13.2018
----------------------------------------------------------------------------------------------------


"""
import numpy as np
from scipy.spatial.distance import pdist, squareform, cdist

from ruptures.exceptions import NotEnoughPoints
from ruptures.base import BaseCost

class CostFDR(BaseCost):
    model = "rbf"

    def __init__(self):
        self.gram = None
        self.min_size = 2

    def fit(self, signal):
        """Sets parameters of the instance.

        Args:
            signal (array): signal. Shape (n_samples,) or (n_samples, n_features)

        Returns:
            self
        """
        if signal.ndim == 1:
            K = pdist(signal.reshape(-1, 1), metric="sqeuclidean")
        else:
            K = pdist(signal, metric="sqeuclidean")  
        # Kcov = cdist(signal, signal, metric="sqeuclidean")
        Kcov = 1000*np.ones((signal.shape[0], 1))
        for i in range(1, signal.shape[0]-1):
            tmp_kcov =  cdist(signal[0:i, :], signal[(i+1):signal.shape[0], :], metric="sqeuclidean")
            Kcov[i] = np.sum(tmp_kcov)/tmp_kcov.shape[0]            
        K = squareform(K)
        K /= Kcov**(0.50)
        self.gram = np.exp(K)
        return self

    def error(self, start, end):
        """Return the approximation cost on the segment [start:end].

        Args:
            start (int): start of the segment
            end (int): end of the segment

        Returns:
            float: segment cost

        Raises:
            NotEnoughPoints: when the segment is too short (less than ``'min_size'`` samples).
        """
        if end - start < self.min_size:
            raise NotEnoughPoints
        sub_gram = self.gram[start:end, start:end]
        val = np.diagonal(sub_gram).sum()
        val -= sub_gram.sum() / (end - start)
        return val
