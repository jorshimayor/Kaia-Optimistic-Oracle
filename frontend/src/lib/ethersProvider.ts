import { ethers } from "ethers";

declare global {
  interface Window {
    ethereum: ethers.providers.ExternalProvider;
  }
}

export const getEthersProvider = () => {
  if (typeof window !== "undefined" && window.ethereum) {
    const provider = new ethers.providers.Web3Provider(window.ethereum);
    return provider;
  }
  throw new Error("No Ethereum provider found");
};
