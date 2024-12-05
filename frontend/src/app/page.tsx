"use client";

import React, { useEffect, useState } from "react";
import { ethers } from "ethers";
import { getEthersProvider } from "../lib/ethersProvider";

const CONTRACT_ADDRESS = "YOUR_DEPLOYED_CONTRACT_ADDRESS";
const CONTRACT_ABI = [
  // Replace with the ABI from your deployed Optimistic Oracle
];

interface Request {
  id: number;
  task: string;
  owner: string;
  status: string;
  deadline: number;
  resolved: boolean;
}

const Home = () => {
  const [requests, setRequests] = useState<Request[]>([]);
  const [contract, setContract] = useState<ethers.Contract | null>(null);

  useEffect(() => {
    const setupContract = async () => {
      const provider = getEthersProvider();
      const signer = provider.getSigner();
      const oracleContract = new ethers.Contract(CONTRACT_ADDRESS, CONTRACT_ABI, signer);
      setContract(oracleContract);
    };

    setupContract();
  }, []);

  const fetchRequests = async () => {
    if (!contract) return;
    const requestCount = await contract.requestCounter();
    const fetchedRequests: Request[] = [];

    for (let i = 1; i <= requestCount.toNumber(); i++) {
      const req = await contract.requests(i);
      fetchedRequests.push({
        id: req.id.toNumber(),
        task: req.task,
        owner: req.owner,
        status: req.status,
        deadline: req.deadline.toNumber(),
        resolved: req.resolved,
      });
    }

    setRequests(fetchedRequests);
  };

  return (
    <div className="flex flex-wrap -mx-3 mb-5">
      <div className="w-full max-w-full px-3 mb-6 mx-auto">
        <div className="relative flex-[1_auto] flex flex-col break-words min-w-0 bg-clip-border rounded-[.95rem] bg-white m-5">
          <div className="relative flex flex-col min-w-0 break-words border border-dashed bg-clip-border rounded-2xl border-stone-200 bg-light/30">
            <div className="px-9 pt-5 flex justify-between items-stretch flex-wrap min-h-[70px] pb-0 bg-transparent">
              <h3 className="flex flex-col items-start justify-center m-2 ml-0 font-medium text-xl/tight text-dark">
                <span className="mr-3 font-semibold text-dark">Optimistic Oracle</span>
                <span className="mt-1 font-medium text-secondary-dark text-lg/normal">
                  List of tasks
                </span>
              </h3>
              <div className="relative flex flex-wrap items-center my-2">
                <button
                  onClick={fetchRequests}
                  className="inline-block text-[.925rem] font-medium leading-normal text-center align-middle cursor-pointer rounded-2xl transition-colors duration-150 ease-in-out text-light-inverse bg-light-dark border-light shadow-none border-0 py-2 px-5 hover:bg-secondary active:bg-light focus:bg-light"
                >
                  Refresh
                </button>
              </div>
            </div>
            <div className="flex-auto block py-8 pt-6 px-9">
              <div className="overflow-x-auto">
                <table className="w-full my-0 align-middle text-dark border-neutral-200">
                  <thead className="align-bottom">
                    <tr className="font-semibold text-[0.95rem] text-secondary-dark">
                      <th className="pb-3 text-start min-w-[175px]">TASK</th>
                      <th className="pb-3 text-end min-w-[100px]">OWNER</th>
                      <th className="pb-3 text-end min-w-[100px]">PROGRESS</th>
                      <th className="pb-3 pr-12 text-end min-w-[175px]">STATUS</th>
                      <th className="pb-3 pr-12 text-end min-w-[100px]">DEADLINE</th>
                    </tr>
                  </thead>
                  <tbody>
                    {requests.map((request) => (
                      <tr key={request.id} className="border-b border-dashed last:border-b-0">
                        <td className="p-3 pl-0">{request.task}</td>
                        <td className="p-3 pr-0 text-end">{request.owner}</td>
                        <td className="p-3 pr-0 text-end">{request.progress}</td>
                        <td className="p-3 pr-12 text-end">{request.status}</td>
                        <td className="p-3 pr-12 text-end">
                          {new Date(request.deadline * 1000).toLocaleString()}
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};

export default Home;
