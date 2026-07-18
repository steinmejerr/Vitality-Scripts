import { useState } from "react";
import { Box, Flex } from "@mantine/core";
import { CharacterList } from "./CharacterList/CharacterList";
import { Register } from "./Register/Register";
import { Header } from "./Header/Header";
import { useRecoilValue } from "recoil";
import { Lang } from "../reducers/atoms";
import { DeletePanel } from "./DeletePanel/DeletePanel";
import classes from "./style.module.css";

export const Panel = () => {
  const lang: any = useRecoilValue(Lang)
  const [title, setTitle] = useState(lang.title_character_selection)
  const [screen, setScreen] = useState("characters");
  return (
    <Box className={classes.container}>
      <Flex className={classes.panel} direction="column">
        <Header title={title} />
        {screen == "characters" && <CharacterList setScreen={setScreen} setTitle={setTitle} />}
        {screen == "register" && <Register setScreen={setScreen} setTitle={setTitle}/>}
        {screen == "delete" && <DeletePanel setScreen={setScreen} setTitle={setTitle} />}
      </Flex>
    </Box>
  );
};
