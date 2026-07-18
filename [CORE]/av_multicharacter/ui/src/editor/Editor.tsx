import { useEffect, useState } from "react"
import {Box, Text, Group, Button, TextInput, Flex, ScrollArea, ActionIcon, Kbd, Stack } from "@mantine/core"
import { IconTrash, IconEdit, IconCopy } from "@tabler/icons-react"
import { fetchNui, useNuiEvent } from "../hooks/useNuiEvents"
import classes from "./style.module.css"

interface Properties {
    handler: string;
    coords: {x: number, y: number, z: number},
    rotation: {x: number, y: number, z:number},
    model: string;
    hash: number;
}

export const Editor = () => {
  const [model, setModel] = useState("")
  const [entities, setEntities] = useState<Properties[]>([])
  const [inCam, setInCam] = useState(false)

  useNuiEvent("cam", () => {
    setInCam(false)
  })
  const handleSpawn = async () => {
    const obj = await fetchNui("av_multicharacter", "newObject", model)
    if(obj){
        setEntities(prevEntities => [...prevEntities, obj])
    }
  }

  const handleEdit = async (entity: Properties) => {
    const obj = await fetchNui("av_multicharacter", "editObject", entity);
    setEntities(prevEntities =>
        prevEntities.map(e => (e.handler === entity.handler ? obj : e))
    );
  };

  const handleDelete = (entity: Properties) => {
    setEntities(prevEntities => {
        const updatedEntities = [...prevEntities];
        const index = updatedEntities.findIndex(e => e.handler === entity.handler);

        if (index !== -1) {
            updatedEntities.splice(index, 1);
        }

        return updatedEntities;
    });
        fetchNui("av_multicharacter", "delObject", entity)
  };

  const handleCopy = (entity: Properties) => {
    fetchNui("av_multicharacter", "copy", entity)
  }

  const handleCam = () => {
    setInCam(true)
    fetchNui("av_multicharacter", "enableCam")
  }

  const instructions = [
    {key: "W A S D", label: "Move"},
    {key: "Q", label: "Up"},
    {key: "E", label: "Down"},
    {key: "Left", label: "Roll Left"},
    {key: "Right", label: "Roll Right"},
    {key: "Up", label: "Zoom In"},
    {key: "Down", label: "Zoom Out"},
    {key: "G", label: "Copy Cam Coords"},
    {key: "Z", label: "Toggle Cam"},
  ]
  const onPressKey = (e: any) => {
    switch (e.code) {
      case "Escape":
        fetchNui("av_multicharacter", "closeEditor")
        break;
      default:
        break;
    }
  };
  useEffect(() => {
    window.addEventListener("keydown", onPressKey);
  }, [])
  
  return (
    <Box className={classes.container}>
        <Flex direction="column" ml="auto" className={classes.box}>
            <Box className={inCam ? classes.noCam : classes.menu} w={inCam ? 200 : 350}>
                {inCam ? <>
                    <Text c="white" fw={600} mt="md">Camera Controls</Text>
                    <Stack mt="md" gap="sm">
                        {instructions.map((info, index) => (
                            <Group key={index} gap="xs">
                                <Kbd>{info.key}</Kbd>
                                <Text fz="sm">{info.label}</Text>
                            </Group>
                        ))}
                    </Stack>
                </> : <>
                    <Text c="white" fw={600}>Create Entity</Text>
                        <Flex direction="column" mt="md">
                            <TextInput placeholder="Model Name" classNames={classes} value={model} onChange={(e)=> {setModel(e.target.value)}} size="xs"/>
                            <Button size="xs" ml="auto" mt="sm" variant="light" color="cyan" onClick={()=>{handleSpawn()}}>Spawn</Button>
                        </Flex>
                        <Text c="white" fw={600} mt="xs">Current Entities</Text>
                        <ScrollArea 
                            h={200} 
                            scrollbars="y"
                            offsetScrollbars
                            scrollbarSize={6}
                            mt="md"
                        >
                            {entities.map((entity, index) => (
                                <Group key={index} p="sm" bg={index % 2 === 1 ? "transparent" : "rgba(0,0,0,0.15)"} style={{borderRadius: '6px'}} >
                                    <Text c="gray.3" fz="sm">{entity.model}</Text>
                                    <Group ml="auto" gap="xs">
                                        <ActionIcon size="xs" c="cyan" variant="transparent" onClick={()=>{handleCopy(entity)}}>
                                            <IconCopy style={{width: "14px", height: "14px"}} stroke={1.5}/>
                                        </ActionIcon>
                                        <ActionIcon size="xs" c="orange" variant="transparent" onClick={()=>{handleEdit(entity)}}>
                                            <IconEdit style={{width: "14px", height: "14px"}} stroke={1.5}/>
                                        </ActionIcon>
                                        <ActionIcon size="xs" c="red" variant="transparent" onClick={()=>{handleDelete(entity)}}>
                                            <IconTrash style={{width: "14px", height: "14px"}} stroke={1.5}/>
                                        </ActionIcon>
                                    </Group>
                                </Group>
                            ))}
                        </ScrollArea>
                </>}
            </Box>
            {!inCam &&
                <Button ml="auto" mt="sm" size="sm" variant="light" color="orange" onClick={()=>{handleCam()}}>Toggle Cam</Button>
            }
        </Flex>
    </Box>
  )
}
