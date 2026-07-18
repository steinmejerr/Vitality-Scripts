import "./App.css";
import "@mantine/core/styles.css";
import { useEffect, useState } from "react";
import { MantineProvider, Transition } from "@mantine/core";
import { useNuiEvent } from "./hooks/useNuiEvents";
import { getLang } from "./hooks/getLang";
import { getSettings } from "./hooks/getSettings";
import { Panel } from "./components/Panel";
import { useSetRecoilState } from "recoil";
import { Editor } from "./editor/Editor";
import { AllCharacters, Lang, CurrentCharacter, Slots, Settings, CanDelete } from "./reducers/atoms";
import {CharacterType } from "./types/types"

interface Parameters {
  characters: CharacterType[];
  state: boolean;
  slots: number;
  canDelete: boolean;
}

const App = () => {
  const setLang = useSetRecoilState(Lang)
  const setSettings = useSetRecoilState(Settings)
  const setCharacterList = useSetRecoilState(AllCharacters)
  const setCurrentCharacter = useSetRecoilState(CurrentCharacter)
  const setSlots = useSetRecoilState(Slots)
  const setCanDelete = useSetRecoilState(CanDelete)
  const [loaded, setLoaded] = useState(false);
  const [showPanel, setShowPanel] = useState(false)
  const [showEditor, setShowEditor] = useState(false)

  useNuiEvent("editor", (state:boolean) => {
    setShowEditor(state)
  })

  useNuiEvent("show", (data: Parameters) => {
    if(data.state) {
      setCharacterList(data.characters)
      setSlots(data.slots)
      setCanDelete(data.canDelete)
      if(data.characters[0]){
        setCurrentCharacter(data.characters[0])
      }
      setShowPanel(data.state);
    } else {
      setShowPanel(false)
      setCurrentCharacter(null)
    }  
  });

  useEffect(() => {
    const init = async () => {
      const lang = await getLang();
      setLang(lang);
      const settings = await getSettings()
      setSettings(settings)
      setLoaded(true)
    };
    init();
  }, []);

  return (
    <>
      {loaded && (
        <MantineProvider defaultColorScheme="dark">
          <Transition
            mounted={showPanel}
            transition="fade"
            duration={400}
            timingFunction="ease"
          >
            {(styles) => (
              <div style={styles}>
                <Panel />
              </div>
            )}
          </Transition>
          {showEditor && <Editor/>}
        </MantineProvider>
      )}
    </>
  );
};

export default App;
