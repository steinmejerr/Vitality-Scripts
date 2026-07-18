export interface CharacterType {
  firstname?: string;
  lastname?: string;
  job?: string;
  slot: number;
  isNew?: boolean;
}

export interface DeleteType {
  character: CharacterType,
  state: boolean
}