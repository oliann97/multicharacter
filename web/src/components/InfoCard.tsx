import React from 'react';
import { Text, Tooltip, Group, Box, useMantineTheme } from '@mantine/core';
import { 
  IconBriefcase, 
  IconBuildingBank, 
  IconCalendarEvent, 
  IconCashBanknote, 
  IconFlag, 
  IconGenderBigender,
  IconId
} from '@tabler/icons-react';

interface InfoCardProps {
  icon: string;
  label: string;
  variant?: 'default' | 'filled' | 'outline';
  size?: 'sm' | 'md' | 'lg';
}

// 图标映射
const iconMap: { [key: string]: (props: {size: number, stroke: number, color: string}) => JSX.Element } = {
  gender: (props) => <IconGenderBigender {...props} />,
  birthdate: (props) => <IconCalendarEvent {...props} />,
  nationality: (props) => <IconFlag {...props} />,
  bank: (props) => <IconBuildingBank {...props} />,
  cash: (props) => <IconCashBanknote {...props} />,
  job: (props) => <IconBriefcase {...props} />,
  identity: (props) => <IconId {...props} />
};

// 标签映射
const labelMap: { [key: string]: string } = {
  gender: "性别",
  birthdate: "出生日期",
  nationality: "国籍",
  bank: "银行存款",
  cash: "现金",
  job: "职业",
  identity: "身份证"
};

const InfoCard: React.FC<InfoCardProps> = ({ 
  icon, 
  label, 
  variant = 'default',
  size = 'md'
}) => {
  const theme = useMantineTheme();
  
  // 根据大小获取图标尺寸
  const getIconSize = () => {
    switch(size) {
      case 'sm': return 16;
      case 'lg': return 24;
      default: return 20;
    }
  };
  
  // 获取颜色
  const getColor = () => {
    if (variant === 'filled') return theme.white;
    return theme.colors.blue[4];
  };
  
  // 获取卡片样式
  const getCardStyle = () => {
    return {
      display: 'flex',
      alignItems: 'center',
      padding: theme.spacing.xs,
      gap: theme.spacing.xs,
      borderRadius: theme.radius.sm,
      backgroundColor: variant === 'filled' ? theme.colors.blue[6] : 'transparent',
      border: variant === 'outline' ? `1px solid ${theme.colors.blue[4]}` : 'none',
      transition: 'all 0.2s ease',
      cursor: 'pointer',
      ':hover': {
        transform: 'translateY(-2px)',
        boxShadow: variant !== 'default' ? theme.shadows.sm : 'none'
      }
    };
  };
  
  const IconComponent = iconMap[icon];
  const iconLabel = labelMap[icon] || icon;
  const iconProps = {
    size: getIconSize(),
    stroke: 1.5,
    color: getColor()
  };

  return (
    <Tooltip 
      label={iconLabel} 
      position="left" 
      withArrow 
      arrowSize={4} 
      color="rgba(20, 30, 50, 0.95)"
    >
      <div 
        className="character-card-charinfo" 
        style={getCardStyle()}
      >
        <div 
          className="info-card-icon" 
          style={{ 
            display: 'flex', 
            alignItems: 'center', 
            justifyContent: 'center' 
          }}
        >
          {IconComponent && IconComponent(iconProps)}
        </div>
        <div className="info-text">
          <Text 
            size={size} 
            style={{ 
              fontWeight: 500, 
              color: variant === 'filled' ? 'white' : undefined 
            }}
          >
            {label}
          </Text>
        </div>
      </div>
    </Tooltip>
  );
};

export default InfoCard;