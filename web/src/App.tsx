import { useState } from "react";
import "./App.css";
import { isEnvBrowser } from "./utils/misc";
import {
	Badge,
	Group,
	Transition,
	Text,
	Button,
	Divider,
	SimpleGrid,
	Title,
	Modal,
	ScrollArea,
} from "@mantine/core";
import { useNuiEvent } from "./hooks/useNuiEvent";
import {
	IconPlayerPlay,
	IconPlus,
	IconUsersGroup,
} from "@tabler/icons-react";
import InfoCard from "./components/InfoCard";
import { fetchNui } from "./utils/fetchNui";
import { useDisclosure } from "@mantine/hooks";
import CreateCharacterModal from "./components/CreateCharacterModal";
import { modals } from "@mantine/modals";

type CharacterMetadata = Array<{ key: string; value: string }>;

interface Character {
	identifier: string;
	name: string;
	metadata: CharacterMetadata;
	cid: number;
}

const formatIdentifier = (identifier: string) => {
	if (identifier.startsWith('char')) {
		const parts = identifier.split(':');
		if (parts.length > 0) {
			return parts[0]; 
		}
	}
	return identifier; 
};

function App() {
	const [visible, setVisible] = useState(isEnvBrowser() ? true : false);
	const [characters, setCharacters] = useState<Character[]>([]);
	const [isSelected, setIsSelected] = useState(-1);
	const [createCharacterId, setCreateCharacterId] = useState(-1);
	const [opened, { open, close }] = useDisclosure(false);
	const [allowedCharacters, setAllowedCharacters] = useState(
		isEnvBrowser() ? 3 : 0
	);
	const [showDeleteButton, setShowDeleteButton] = useState(true);
	const [deleteModalOpened, setDeleteModalOpened] = useState(false);
	const [characterToDelete, setCharacterToDelete] = useState("");

	useNuiEvent<{ characters: Character[]; allowedCharacters: number; showDeleteButton: boolean }>(
		"showMultiChar",
		(data) => {
			setCharacters(data.characters);
			setAllowedCharacters(data.allowedCharacters);
			setVisible(true);
			if (data.showDeleteButton !== undefined) {
				setShowDeleteButton(data.showDeleteButton);
			}
			if (data.characters && data.characters.length > 0) {
				const firstCharacter = data.characters[0];
				HandleSelect(firstCharacter.cid, firstCharacter.identifier);
			}
		}
	);

	const HandleSelect = async (key: number, identifier: string) => {
		await fetchNui<number>(
			"selectCharacter",
			{ identifier: identifier },
			{ data: 1 }
		);
		setIsSelected(key);
	};

	const HandlePlay = async (identifier: string, cid: number) => {
		setVisible(false);
		setCharacters([]);
		setIsSelected(-1);
		await fetchNui<number>(
			"playCharacter",
			{ identifier: identifier, cid: cid },
			{ data: 1 }
		);
	};

	const HandleDelete = async (identifier: string) => {
		setDeleteModalOpened(false);
		setVisible(false);
		setCharacters([]);
		setIsSelected(-1);
		await fetchNui<number>(
			"deleteCharacter",
			{ identifier: identifier },
			{ data: 1 }
		);
	};

	const HandleCreate = () => {
		close();
		setVisible(false);
		setCharacters([]);
		setIsSelected(-1);
	};

	const openDeleteModal = (identifier: string) => {
		setCharacterToDelete(identifier);
		setDeleteModalOpened(true);
	};

	return (
		<>
			<Modal
				opened={opened}
				onClose={close}
				title={"创建新角色 " + (createCharacterId + 1)}
				centered
				radius="sm"
				overlayProps={{ 
					color: "rgba(10, 11, 15, 0.95)",
					blur: 5 
				}}
				styles={{
					header: {
						backgroundColor: "rgba(13, 17, 23, 0.8)",
						padding: "16px",
						borderBottom: "1px solid rgba(255, 255, 255, 0.05)"
					},
					title: {
						color: "#fff",
						fontSize: "16px",
						fontWeight: 500
					},
					content: {
						backgroundColor: "rgba(15, 19, 26, 0.95)",
						backdropFilter: "blur(20px)"
					}
				}}
			>
				<CreateCharacterModal
					id={createCharacterId + 1}
					handleCreate={HandleCreate}
				/>
			</Modal>

			<Modal
				opened={deleteModalOpened}
				onClose={() => setDeleteModalOpened(false)}
				title="删除角色"
				centered
				radius="sm"
				overlayProps={{ 
					color: "rgba(10, 11, 15, 0.95)",
					blur: 5 
				}}
				styles={{
					header: {
						backgroundColor: "rgba(13, 17, 23, 0.8)",
						padding: "16px",
						borderBottom: "1px solid rgba(255, 255, 255, 0.05)"
					},
					title: {
						color: "#fff",
						fontSize: "16px",
						fontWeight: 500
					},
					content: {
						backgroundColor: "rgba(15, 19, 26, 0.95)",
						backdropFilter: "blur(20px)"
					}
				}}
			>
				<div style={{ padding: "20px" }}>
					<Text size="sm" mb={20}>您确定要删除此角色吗？此操作无法撤销。</Text>
					<Group justify="flex-end" gap="md">
						<Button 
							color="blue" 
							variant="subtle" 
							radius="sm" 
							onClick={() => setDeleteModalOpened(false)}
						>
							取消
						</Button>
						<Button 
							color="red" 
							radius="sm" 
							onClick={() => HandleDelete(characterToDelete)}
						>
							确认删除
						</Button>
					</Group>
				</div>
			</Modal>

			<div className={`app-container`}>
				<div className="background-elements">
					<div className="circle circle-1"></div>
					<div className="circle circle-2"></div>
					<div className="circle circle-3"></div>
				</div>
				<div className='container'>
					

					<Transition transition='slide-up' mounted={visible}>
						{(style) => (
							<ScrollArea style={{ ...style }} h={700} scrollbarSize={3} offsetScrollbars>
								<div className='multichar'>
									{[...Array(allowedCharacters)].map((_, index) => {
										const character = characters[index];
										return character ? (
											<div className='character-card' key={character.identifier}>
												<div className='character-card-header'>
													<Text fw={600} fz="sm" c="rgba(255, 255, 255, 0.95)">{character.name}</Text>
													<Badge
														color='blue'
														variant='light'
														radius='sm'
														className='identifier-badge'
													>
														{formatIdentifier(character.identifier)}
													</Badge>
												</div>

												<div className='character-card-content'>
													<div
														className={
															isSelected === character.cid ? "show" : "hide"
														}
													>
														<SimpleGrid cols={2} spacing={10}>
															{character.metadata &&
																character.metadata.length > 0 &&
																character.metadata.map((metadata) => (
																	<InfoCard
																		key={metadata.key}
																		icon={metadata.key}
																		label={metadata.value}
																	/>
																))}
														</SimpleGrid>

														<Divider color='rgba(30, 50, 90, 0.3)' my={18} />

														<div className='character-card-actions'>
															<Button
																color='teal'
																variant='filled'
																fullWidth
																leftSection={<IconPlayerPlay size={14} />}
																h={38}
																radius="sm"
																onClick={() => {
																	HandlePlay(character.identifier, character.cid);
																}}
															>
																扮演该角色
															</Button>
															
															{showDeleteButton && (
																<Button
																	color='red'
																	variant='light'
																	fullWidth
																	h={38}
																	radius="sm"
																	onClick={() => openDeleteModal(character.identifier)}
																>
																	删除角色
																</Button>
															)}
														</div>
													</div>

													<div
														className={
															isSelected === character.cid ? "hide" : "show"
														}
													>
														<Button
															color='blue'
															variant='filled'
															fullWidth
															h={38}
															radius="sm"
															onClick={() => {
																HandleSelect(character.cid, character.identifier);
															}}
														>
															选择
														</Button>
													</div>
												</div>
											</div>
										) : (
											<div
												className='character-card create-card'
												key={`create-${index}`}
											>
												<div className='character-card-header'>
													<Text fw={500} fz="xs" c="rgba(255, 255, 255, 0.85)">新角色 #{index + 1}</Text>
													<Badge
														color='blue'
														variant='light'
														radius='sm'
														className='identifier-badge'
													>
														待创建
													</Badge>
												</div>
												<div className='character-card-content'>
													<div className="create-card-content">
														<Button
															color='blue'
															variant='outline'
															fullWidth
															leftSection={<IconPlus size={16} />}
															h={42}
															radius="sm"
															onClick={() => {
																open();
																setCreateCharacterId(index);
															}}
														>
															创建新角色
														</Button>
														<Text size="xs" c="dimmed" ta="center" mt={14}>
															点击创建您的第 {index + 1} 个角色
														</Text>
													</div>
												</div>
											</div>
										);
									})}
								</div>
							</ScrollArea>
						)}
					</Transition>
				</div>
			</div>
		</>
	);
}

export default App;
