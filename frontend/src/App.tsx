import { ConnectButton } from '@rainbow-me/rainbowkit'
import { useAccount } from 'wagmi'
import UserStats from './components/UserStats'

export default function App() {
  const { isConnected } = useAccount()

  return (
    <div className="min-h-screen flex flex-col">
      {/* Header */}
      <header className="p-6 border-b border-surface">
        <div className="max-w-6xl mx-auto flex justify-between items-center">
          <h1 className="text-4xl font-bold text-primary">RacePredict</h1>
          <ConnectButton />
        </div>
      </header>

      {/* Main Content */}
      <main className="flex-1 max-w-6xl mx-auto p-6 w-full">
        {isConnected ? (
          <div>
            <UserStats />
            <div className="text-center py-12">
              <p className="text-2xl text-accent">Markets loading soon — place bets on F1 races 🏎️🔥</p>
            </div>
          </div>
        ) : (
          <div className="text-center py-20">
            <h2 className="text-4xl font-bold mb-8 text-primary">Connect Wallet to Predict F1 Races</h2>
            <ConnectButton />
          </div>
        )}
      </main>

      {/* Footer */}
      <footer className="py-8 border-t border-surface mt-auto">
        <div className="text-center text-muted">
          Built by{' '}
          <a
            href="https://x.com/Genius_devv"
            target="_blank"
            rel="noopener noreferrer"
            className="text-primary hover:text-accent underline"
          >
            @Genius_devv 
          </a>
        </div>
      </footer>
    </div>
  )
}
