import { useAccount, useReadContract } from 'wagmi'
import factoryAbi from '../abi/MarketFactory.json'

const FACTORY_ADDRESS = import.meta.env.VITE_FACTORY_ADDRESS as `0x${string}`

export default function UserStats() {
  const { address } = useAccount()
  
  const { data: stats, isLoading, error } = useReadContract({
    address: FACTORY_ADDRESS,
    abi: factoryAbi,
    functionName: 'userStats',
    args: address ? [address] : undefined,
  })

  if (!address) return null
  if (isLoading) return <p className="text-center text-muted">Loading stats...</p>
  if (error || !stats) return <p className="text-center text-muted">No stats yet — place your first bet! 🏎️</p>

  const formatEth = (wei: bigint) => (Number(wei) / 1e18).toFixed(4)

  return (
    <div className="bg-surface/80 backdrop-blur rounded-xl p-6 mb-8 border border-primary/30 shadow-2xl">
      <h2 className="text-2xl font-bold text-primary mb-6 text-center">Your RacePredict Stats 🍊💊</h2>
      <div className="grid grid-cols-2 md:grid-cols-4 gap-6">
        <div className="text-center bg-background/50 rounded-lg p-4">
          <p className="text-muted text-sm">Volume</p>
          <p className="text-3xl font-bold text-accent">{formatEth(stats.totalVolume)} ETH</p>
        </div>
        <div className="text-center bg-background/50 rounded-lg p-4">
          <p className="text-muted text-sm">Points</p>
          <p className="text-3xl font-bold text-primary">{Number(stats.points)}</p>
        </div>
        <div className="text-center bg-background/50 rounded-lg p-4">
          <p className="text-muted text-sm">Trades</p>
          <p className="text-3xl font-bold text-accent">{Number(stats.tradesCount)}</p>
        </div>
        <div className="text-center bg-background/50 rounded-lg p-4">
          <p className="text-muted text-sm">Wins</p>
          <p className="text-3xl font-bold text-green-400">{Number(stats.winsCount)}</p>
        </div>
      </div>
    </div>
  )
}
