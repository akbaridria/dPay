export interface Menus {
  name: string,
  link: string,
  icon: string
}

export interface Benefits {
  image: string,
  title: string,
  subtitle: string
}

export interface StreamingFlow {
  number: string,
  title: string,
  description: string
}

export interface DetailChain {
  chainName: string,
  chainId: string,
  nativeCurrency: {
    name: string,
    decimals: string,
    symbol: string
  }
  rpcUrls: string[]
}

export interface Rate {
  rate: number
}

export type FlowRate = "seconds" | "hours" | "days" | "months" | "years"

export interface FormStream {
  recipient: string | null,
  flowAmount: number | null,
  flowRate: FlowRate,
  totalAmount: number | null
}

export interface ListSender {
  id: number,
  sender: string,
  recipient: string,
  amount: number,
  remainingBalance: number,
  ratePerSecond: number,
  starttime: number,
  availabeAmount: string
}

export interface FormStreamMore {
  id: number,
  totalAmount: number,
  recipient: string,
  remainingBalance: number
}